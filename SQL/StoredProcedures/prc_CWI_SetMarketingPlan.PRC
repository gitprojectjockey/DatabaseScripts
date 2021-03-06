/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMarketingPlan]    Script Date: 5/21/2014 11:01:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMarketingPlan]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetMarketingPlan]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetMarketingPlan]    Script Date: 5/21/2014 11:01:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetMarketingPlan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetMarketingPlan 
* Purpose : This PROC would be called to insert/update the marketing plan 
* Invoked from : MarketingPlan.aspx.cs
* CREATED: MohanKumar 14JUN13
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  

exec [prc_CWI_SetMarketingPlan] @PlanId = 0 OUT,
	@DivisionID = 123,
	@PlanName= ''Plan1'',
	@PlanDesc = ''Plan Desc'',
	@PlanFrom = ''07/01/2013'',
	@PlanTo = ''07/31/2013'',
	@PlanBudget = 4000.00,
	@Author =2

**********************************************************************/ 

----------------------------------------------------------------------------
-- Insert a single record into CWI_MarketingPlan
----------------------------------------------------------------------------
CREATE PROC [dbo].[prc_CWI_SetMarketingPlan]
	@PlanId int = 0 OUT,
	@DivisionID int,
	@PlanName varchar(255),
	@PlanDesc varchar(1000),
	@PlanFrom datetime,
	@PlanTo datetime,
	@PlanBudget money,
	@Author int
	
AS
	DECLARE @ClientId int
	SET @ClientId = NULL

	declare @message NVARCHAR(2000) 

	SELECT @ClientId = ParentID FROM CWI_Client
	WHERE Id = @DivisionID

	IF @ClientId IS NULL
	BEGIN
		SET @message = ''Can not create plan for client. Please select division'';
		THROW 50000,@message , 1; 
	END

	DECLARE @AuthorName varchar(1000)
	DECLARE @dt varchar(50)
	SET @dt = FORMAT( getdate(), ''MM/dd/yyyy hh:mm tt'')
	
	SELECT @AuthorName = Names FROM CWI_User WHERE Id = @Author

	IF @PlanId = 0
	BEGIN

		IF EXISTS(
			SELECT 
				top 1 1
			FROM CWI_MarketingPlan
			where PlanName = @PlanName
				and (DivisionID = @DivisionID )
				)
		BEGIN
			SET @message = ''Plan name already exists for the division'';
			THROW 50000,@message , 1; 
		END
				
		IF EXISTS(
			SELECT 
				top 1 1
			FROM CWI_MarketingPlan
			where 
			((@PlanFrom between  PlanFrom  and PlanTo)
			OR ( @PlanTo between  PlanFrom  and PlanTo )
			)
			
				and (DivisionID = @DivisionID )
				)
		BEGIN
			SET @message = ''Plan already exists for the term'';
			THROW 50000,@message , 1; 
		END


		BEGIN TRANSACTION
		BEGIN TRY
			INSERT CWI_MarketingPlan
			(
				DivisionID, 
				PlanName, 
				PlanDescription,
				PlanFrom, 
				PlanTo, 
				PlanBudget,
				CreatedBy, 
				CreatedOn, 
				ModifiedBy, 
				ModifiedOn
			)
			VALUES 
			(
				@DivisionID, 
				@PlanName, 
				@PlanDesc,
				@PlanFrom, 
				@PlanTo,  
				@PlanBudget,
				@Author, 
				getdate(), 
				@Author, 
				getdate()
			)

			SET @PlanId =  SCOPE_IDENTITY()
			declare @InsertAction varchar(8000)

			SET @InsertAction = ''Marketing Plan created by '' + @AuthorName + '' on '' + @dt

			EXEC prc_CWI_SetAction @ObjectLookupId = 204, @ObjectId = @PlanId,
				@ActionLookupId = 10001,
				@Action = @InsertAction,
				@ActionWithLink = @InsertAction,
				@CreatedBy = @Author

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;
	END
	ELSE
	BEGIN

		IF EXISTS(
			SELECT 
				top 1 1
			FROM CWI_MarketingPlan
			where PlanName = @PlanName
				and (DivisionID = @DivisionID ) and Id <>@PlanId
				)
		BEGIN
			SET @message = ''Plan name already exists for the division'';
			THROW 50000,@message , 1; 
		END

		IF EXISTS(
			SELECT 
				top 1 1
			FROM CWI_MarketingPlan
			where 
			((@PlanFrom between  PlanFrom  and PlanTo)
			OR ( @PlanTo between  PlanFrom  and PlanTo )
			)
				and (DivisionID = @DivisionID )
				and Id <>@PlanId
				)
		BEGIN
			SET @message = ''Plan already exists for the term'';
			THROW 50000,@message , 1; 
		END

		DECLARE @ExistPlanFrom datetime,@ExistPlanTo datetime

		SELECT @ExistPlanFrom = PlanFrom, @ExistPlanTo = PlanTo FROM CWI_MarketingPlan WHERE Id = @PlanId

		IF @ExistPlanFrom <> @PlanFrom OR @ExistPlanTo <> @PlanTo /* Plan term changes */
		Begin
			IF EXISTS(SELECT TOP 1 1 FROM CWI_Job 
			WHERE MarketingPlanId = @PlanId
			AND (InvoiceDate <= @PlanFrom
			OR InvoiceDate >= @PlanTo))
			begin
				SET @message = ''Existing job not within new plan term'';
				THROW 50000,@message , 1; 
			end

		End

		DECLARE @jobcount int
		SELECT @jobcount = JobCount FROM CWI_MarketingPlan WHERE ID = @PlanId

		/*IF (@jobcount>0)
		BEGIN
			SET @message = ''Job exists for the plan'';
			THROW 50000,@message , 1; 
		END
		*/

		BEGIN TRANSACTION
		BEGIN TRY
			IF (@jobcount>0) -- If job already exists, division is not updated
			BEGIN
			
				UPDATE	
					CWI_MarketingPlan
				SET	
					PlanName = @PlanName,
					PlanDescription =  @PlanDesc ,
					PlanFrom = @PlanFrom,
					PlanTo = @PlanTo,
					PlanBudget = @PlanBudget,
					ModifiedBy = @Author,
					ModifiedOn = getdate()
				WHERE 	ID = @PlanId
			END
			ELSE
			BEGIN
				UPDATE	
					CWI_MarketingPlan
				SET	DivisionID = @DivisionID,
					PlanName = @PlanName,
					PlanDescription =  @PlanDesc ,
					PlanFrom = @PlanFrom,
					PlanTo = @PlanTo,
					PlanBudget = @PlanBudget,
					ModifiedBy = @Author,
					ModifiedOn = getdate()
				WHERE 	ID = @PlanId
			END
			declare @UpdateAction varchar(8000)

			SET @UpdateAction = ''Marketing Plan updated by '' + @AuthorName + '' on '' + @dt

			EXEC prc_CWI_SetAction @ObjectLookupId = 204, @ObjectId = @PlanId,
				@ActionLookupId = 10002,
				@Action = @UpdateAction,
				@ActionWithLink = @UpdateAction,
				@CreatedBy = @Author


		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT >0 
				ROLLBACK TRANSACTION ;
			EXEC prc_CWI_AppRaiseError; 
			THROW
		END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION Trans1;
	END
' 
END
GO


