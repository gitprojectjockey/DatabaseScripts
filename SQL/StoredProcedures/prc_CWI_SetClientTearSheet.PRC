/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientTearSheet]    Script Date: 6/19/2013 2:19:07 PM *****/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_SetClientTearSheet' )
 DROP PROCEDURE [dbo].[prc_CWI_SetClientTearSheet]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetClientTearSheet]    Script Date: 6/19/2013 2:19:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************  
* PROCEDURE: [prc_CWI_SetClientTearSheet]
* Purpose : This PROC would be called TO INSERT OR UPDATE the client tear sheet details
* Invoked from : Client_TearSheet.ascx
* CREATED: Vijesh Mahi
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetClientTearSheet 
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetClientTearSheet]
@inTearSheetId int,
@inClientID int,
@vcTearName varchar(255),	
@vcAddressLine1 varchar(255),
@vcAddressLine2  varchar(255)=NULL,
@intCountryID  int,
@intStateID int,
@vcCity varchar(50),
@vcZip varchar(50),
@vcWorkPhone varchar(50)=NULL,
@vcWorkExtn varchar(10)=NULL,
@vcWorkFax varchar(50)=NULL,
@vcTearContact varchar(500),
@inCreatedBy int,
@inNewTearId int out
AS
BEGIN
	DECLARE @inAddressID int
	BEGIN TRY
		IF @inTearSheetId IS NULL
		BEGIN
			INSERT INTO dbo.CWI_Address
			(AddressLine1,AddressLine2,CountryID,StateID,City,Zip,WorkPhone,WorkExtn,WorkFax,CreatedBy)
			VALUES
			(@vcAddressLine1,@vcAddressLine2,@intCountryID,@intStateID,@vcCity,@vcZip,@vcWorkPhone,@vcWorkExtn,
			@vcWorkFax,@inCreatedBy)

			SET @inAddressID = @@IDENTITY

			INSERT INTO dbo.CWI_ClientTearSheet
			([ClientId],[AddressId],[TearName],[TearContact],[CreatedBy],[CreatedOn],[ModifiedBy],[ModifiedOn])
			VALUES
			(@inClientID,@inAddressID,@vcTearName,@vcTearContact,@inCreatedBy,GETDATE(),@inCreatedBy,GETDATE())
			SET @inNewTearId = @@IDENTITY
		END
		ELSE
		BEGIN
			SET @inNewTearId=@inTearSheetId
			SET @inAddressID = (SELECT AddressID FROM [dbo].[CWI_ClientTearSheet] WHERE Id = @inTearSheetId)

			UPDATE [dbo].[CWI_Address] 
			SET [AddressLine1] = @vcAddressLine1,[AddressLine2] = @vcAddressLine2
				  ,[CountryID] = @intCountryID,[StateID] = @intStateID,[City] = @vcCity,[Zip] = @vcZip
				  ,[WorkPhone] = @vcWorkPhone,[WorkExtn] = @vcWorkExtn,[WorkFax] = @vcWorkFax
				  ,[ModifiedBy] = @inCreatedBy,[ModifiedOn] = GETDATE()
			 WHERE  ID = @inAddressID

			 UPDATE [dbo].[CWI_ClientTearSheet]
			 SET [TearName]=@vcTearName,[TearContact]=@vcTearContact,ModifiedBy=@inCreatedBy,ModifiedOn=GETDATE()
			 WHERE Id=@inTearSheetId
		END

		declare @isDataSyncOn bit,
						@intParentID int,
						@vcClientCode varchar(3),
						@vcStateCode varchar(2)

			set @isDataSyncOn = (Select case when LookupName = 'YES' then 1 else 0 end
																			from Lookup
																			Where ID = 6151 and LookupTypeID = 25)--DataSyncToTmimmrdb
			 if @isDataSyncOn = 1
			 BEGIN
						set @intParentID = (Select isnull(ParentID,0) from CWI_Client 
																	where ID = @inClientID)


						if @intParentID != 0 --this is a Division, so we update TearSheet Info for the Division
						BEGIN
								set @vcClientCode = (Select ClientCode from CWI_Client
																				where ID = @inClientID)

								set @vcStateCode = (Select StateCode from [State] where ID = @intStateID)

								Update mmis.tmimmrdb.dbo.Client
									Set TearName = @vcTearName,
											TearContact = @vcTearContact,
											TearAddr1 = @vcAddressLine1,
											TearAddr2 = @vcAddressLine2,
											TearCity = @vcCity,
											TearStCode = @vcStateCode,
											TearZip = @vcZip
								where CliCode = @vcClientCode

						END
			 END



	END TRY
	BEGIN CATCH
		EXEC prc_CWI_AppRaiseError;
		THROW;   
	END CATCH
END
GO
