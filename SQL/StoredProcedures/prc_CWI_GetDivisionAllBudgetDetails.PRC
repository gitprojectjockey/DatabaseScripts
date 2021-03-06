/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionAllBudgetDetails]    Script Date: 9/16/2014 2:49:18 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionAllBudgetDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetDivisionAllBudgetDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetDivisionAllBudgetDetails]    Script Date: 9/16/2014 2:49:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetDivisionAllBudgetDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************  
* PROCEDURE: [prc_CWI_GetDivisionAllBudgetDetails]  
* Purpose : This PROC would be called to get the details with Division budget
* Invoked from : Client Budget.ascx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec prc_CWI_GetDivisionAllBudgetDetails @ClientBudgetId=2, @divisionId= 14190, @SearchFor = ''M'',@ClassifciationId = 0 --MOnthlywise Budget CLientBudegetId and DivisioI
exec prc_CWI_GetDivisionAllBudgetDetails @ClientBudgetId=1017, @divisionId= 14190,@BudgetDate = ''2013-06-01'', @SearchFor = ''C'' --Classwise Budget CLientBudegetId and DivisioI
exec prc_CWI_GetDivisionAllBudgetDetails @ClientBudgetId=1017, @divisionId= 14190,@BudgetDate = ''2013-06-01'',@ClassifciationId = 401, @SearchFor = ''V'' --Classwise Budget CLientBudegetId and DivisioId
exec prc_CWI_GetDivisionAllBudgetDetails @ClientBudgetId=2, @divisionId= 13959,@BudgetDate = ''2013-03-01'',@ClassifciationId = 402, @SearchFor = ''S'' --Classwise Budget CLientBudegetId and DivisioId

 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetDivisionAllBudgetDetails] 
	@ClientBudgetId	int , 
	@DivisionId	int,
	@BudgetDate datetime = NULL,
	@ClassifciationId     int = NULL,
	@BudgetMonthInvoiceId int=NULL,
	@SearchFor varchar(4)
	

AS
BEGIN

	DECLARE @BudgetFrom datetime
	DECLARE @BudgetTo datetime
	SET @BudgetFrom = NULL



	IF @SearchFor = ''M''
	begin
		DECLARE @DivisionBudgetId int
		SET @DivisionBudgetId = NULL
		SELECT top 1 @BudgetFrom =CB.BudgetFrom ,@BudgetTo =CB.BudgetTo , @DivisionBudgetId = DB.ID  FROM CWI_DivisionBudget DB
		INNER JOIN CWI_ClientBudget CB ON CB.Id = DB.ClientBudgetID
		WHERE  DB.ClientBudgetID = @ClientBudgetId AND DB.DivisionID = @DivisionId
		
		
		IF @DivisionBudgetId IS NOT NULL
		BEGIN
			SELECT 
				ISNULL(BM.Id,0) as Id,
				ISNULL(dbo.fnc_GetMonth(BM.[Month]) + ''-'' + CAST(BM.[Year] AS VARCHAR(10)),M.[MonthName] + ''-'' + CAST(M.[Year] AS VARCHAR(10))) DisplayName,
				CAST(ISNULL(BM.BudgetAvailable,0) as decimal(18,2)) BudgetAvailable,
	 			CAST(ISNULL(BM.BudgetForecast,0)	as decimal(18,2)) BudgetForecast,
				CAST(ISNULL(BM.BudgetUsed,0) AS decimal(18,2)) BudgetUsed,
				CAST(ISNULL(BM.BudgetCommitted,0) AS decimal(18,2)) BudgetCommitted,
				MonthStartDate BudgetDate, 
				BM.DivisionBudgetId,
				0 as Unavailable,
				 cast(NULL AS VARCHAR(15)) ParentKey ,
				 ''M'' [Level],
				cast(convert(date, MonthStartDate,101) as varchar(20))  DataKey
			FROM CWI_BudgetMonth BM
			RIGHT OUTER JOIN dbo.fnc_GetMonths(@BudgetFrom, @BudgetTo) M
				ON M.MonthNumber = BM.Month AND M.[Year] = BM.[Year] AND  DivisionBudgetID =  @DivisionBudgetId
			ORDER BY M.MonthStartDate
		END
		ELSE
		BEGIN
			SELECT top 1 @BudgetFrom =BudgetFrom ,@BudgetTo =BudgetTo  FROM CWI_ClientBudget CB 
			WHERE ID =  @ClientBudgetId

			SELECT 
				0 Id,
				M.[MonthName] + ''-'' + CAST(M.[Year] AS VARCHAR(10)) DisplayName,
				CAST(0 as decimal(18,2)) BudgetAvailable,
	 			CAST(0	as decimal(18,2)) BudgetForecast,
				CAST(0 AS decimal(18,2)) BudgetUsed,
				CAST(0 AS decimal(18,2)) BudgetCommitted,
				MonthStartDate Unavailable,
				Cast(NULL as VARCHAR(10)) ParentKey,
				 ''M'' [Level],
				cast(convert(date, MonthStartDate,101) as varchar(20)) DataKey
			FROM dbo.fnc_GetMonths(@BudgetFrom, @BudgetTo) M
				
			ORDER BY M.MonthStartDate
		END	

		
	end

	ELSE IF @SearchFor = ''C''
	begin
		DECLARE @BudgetMonthId int
		SET @BudgetMonthId = NULL

		SELECT top 1 @BudgetMonthId =BM.ID  FROM CWI_DivisionBudget DB
		INNER JOIN CWI_ClientBudget CB ON CB.Id = DB.ClientBudgetID
		INNER JOIN CWI_BudgetMonth BM ON BM.DivisionBudgetID = DB.ID
		WHERE  DB.ClientBudgetID = @ClientBudgetId AND DB.DivisionID = @DivisionId
		AND BM.Month = Month(@BudgetDate) AND BM.Year = Year(@BudgetDate)

		IF @BudgetMonthId IS NOT NULL
		BEGIN
		WITH CTEC (ID,BudgetMonthId,DisplayName,BudgetAvailable,BudgetForecast,BudgetUsed,BudgetCommitted,Unavailable,ParentKey,DataKey,[Level])

			
AS
(SELECT 
				ISNULL(BMc.Id,0) as Id,
				ISNULL(@BudgetMonthId,0) as BudgetMonthId,
				C.LookupName DisplayName,
				CAST(ISNULL(BMC.BudgetAvailable,0) as decimal(18,2)) BudgetAvailable,
	 			CAST(ISNULL(BMC.BudgetForecast,0)	as decimal(18,2)) BudgetForecast,
				CAST(ISNULL(BMC.BudgetUsed,0) AS decimal(18,2)) BudgetUsed,
				CAST(ISNULL(BMC.BudgetCommitted,0) AS decimal(18,2)) BudgetCommitted,
				cast(C.ID AS VARCHAR(10)) Unavailable,
				cast(convert(date, @BudgetDate,101) as varchar(20))  ParentKey,
				cast(C.ID as VARCHAR(10)) DataKey,
				 ''C'' [Level]
			FROM CWI_BudgetMonthClassification BMC
			RIGHT OUTER JOIN vw_CWI_Classification C
				ON BMC.ClassificationLookupID = C.ID AND  BMC.BudgetMonthID =  @BudgetMonthId)


					SELECT 
				--ISNULL(BMs.Id,0) as ServiceId,
				CASE WHEN CTEC.[Level]= ''C''
				THEN ISNULL(CTEC.ID,0)
				ELSE ISNULL(BMS.ID,0) END Id,
				ISNULL(@BudgetMonthId,0) as BudgetMonthId,
				CASE WHEN CTEC.[Level]= ''C''
				THEN CTEC.DisplayName
				 ELSE s.ServiceCode+'' - ''+ s.ServiceName END DisplayName,

				CASE WHEN CTEC.[Level]= ''C''
				THEN CAST(ISNULL(CTEC.BudgetAvailable,0) as decimal(18,2)) 
				ELSE CAST(ISNULL(BMS.BudgetAvailable,0) as decimal(18,2))  END BudgetAvailable,
				CASE WHEN CTEC.[Level]= ''C''
				THEN CAST(ISNULL(CTEC.BudgetForecast,0) as decimal(18,2)) 
				ELSE CAST(ISNULL(BMS.BudgetForecast,0) as decimal(18,2))  END BudgetForecast,
				CASE WHEN CTEC.[Level]= ''C''
				THEN CAST(ISNULL(CTEC.BudgetUsed,0) as decimal(18,2)) 
				ELSE CAST(ISNULL(BMS.BudgetUsed,0) as decimal(18,2))  END BudgetUsed,
				CASE WHEN CTEC.[Level]= ''C''
				THEN CAST(ISNULL(CTEC.BudgetCommitted,0) as decimal(18,2)) 
				ELSE CAST(ISNULL(BMS.BudgetCommitted,0) as decimal(18,2))  END BudgetCommitted,
				CASE WHEN CTEC.[Level]= ''C''
				THEN CAST(ISNULL(CTEC.Unavailable,0) as VARCHAR(10)) 
				ELSE CAST(ISNULL(S.Id,0) as VARCHAR(10))  END Unavailable,
				CASE WHEN CTEC.[Level]= ''C''
				THEN CAST(ISNULL(CTEC.DataKey,0) as VARCHAR(10)) 
				ELSE CAST(ISNULL(S.ID,0) as VARCHAR(10))  END DataKey,
				cast(convert(date, @BudgetDate,101) as varchar(20))  ParentKey,
				--cast(ISNULL( S.ID,CTEC.DataKey) as VARCHAR(10)) DataKey,
			
				 CASE WHEN CTEC.[Level]= ''C''
				 THEN ''C''
				 ELSE ''S'' END [Level]
			FROM CWI_BudgetMonthService BMS
			right OUTER JOIN CWI_Service S
				ON BMS.ServiceID = S.ID AND  BMS.BudgetMonthID =  @BudgetMonthId
				 --Inner join CWI_BudgetMonth on CWI_BudgetMonth.id=bms.BudgetMonthId
				FULL OUTER JOIN CTEC ON CTEC.BudgetMonthId = BMS.ID
				ORDER BY [LEVEL]
		END
		ELSE
		BEGIN
			WITH CTEC (ID,BudgetMonthId,DisplayName,BudgetAvailable,BudgetForecast,BudgetUsed,BudgetCommitted,Unavailable,ParentKey,DataKey,[Level])
AS
(SELECT 
				0 Id,
				ISNULL(@BudgetMonthId,0) as BudgetMonthId,
				C.LookupName  DisplayName,				
				CAST(0 as decimal(18,2)) BudgetAvailable,
	 			CAST(0	as decimal(18,2)) BudgetForecast,
				CAST(0 AS decimal(18,2)) BudgetUsed,
				CAST(0 AS decimal(18,2)) BudgetCommitted,
				cast(C.ID AS VARCHAR(10)) Unavailable,
				cast(convert(date, @BudgetDate,101) as varchar(20))  ParentKey,
				cast(C.ID as VARCHAR(10)) DataKey,
				 ''C'' [Level]
				
			FROM vw_CWI_Classification C
			WHERE C.IsActive = 1
			)


					SELECT 
				ISNULL(BMS.Id,0) as Id,
				ISNULL(@BudgetMonthId,0) as BudgetMonthId,
				ISNULL(s.ServiceCode+'' - ''+ s.ServiceName ,CTEC.DisplayName) as DisplayName,
				CAST(ISNULL(BMS.BudgetAvailable,0) as decimal(18,2)) BudgetAvailable,
	 			CAST(ISNULL(BMS.BudgetForecast,0)	as decimal(18,2)) BudgetForecast,
				CAST(ISNULL(BMS.BudgetUsed,0) AS decimal(18,2)) BudgetUsed,
				CAST(ISNULL(BMS.BudgetCommitted,0) AS decimal(18,2)) BudgetCommitted,
				cast(ISNULL(S.ID,CTEC.Unavailable) AS VARCHAR(10)) Unavailable,
				cast(convert(date, @BudgetDate,101) as varchar(20))  ParentKey,
				cast(ISNULL( S.ID,CTEC.DataKey) as VARCHAR(10)) DataKey,
				--cast(CTEC.ID AS VARCHAR(10)) CUnavailable,
				--cast(CTEC.ID as VARCHAR(10)) CDataKey,
				 case when s.ServiceName  IS NULL
				 THEN ''C''
				 ELSE ''S'' END [Level]
			FROM CWI_BudgetMonthService BMS
			Right OUTER JOIN CWI_Service S
				ON BMS.ServiceID = S.ID AND  BMS.BudgetMonthID =  @BudgetMonthId
				 --Inner join CWI_BudgetMonth on CWI_BudgetMonth.id=bms.BudgetMonthId
				Full OUTER JOIN CTEC ON CTEC.BudgetMonthId = BMS.ID
				ORDER BY [LEVEL]
		END
	end

	ELSE IF @SearchFor = ''V''
	begin

		DECLARE @BudgetMonthClassificationID int
		SET @BudgetMonthClassificationID = NULL

		SELECT top 1 @BudgetMonthClassificationID =BMC.ID  FROM CWI_DivisionBudget DB
		INNER JOIN CWI_ClientBudget CB ON CB.Id = DB.ClientBudgetID
		INNER JOIN CWI_BudgetMonth BM ON BM.DivisionBudgetID = DB.ID
		INNER JOIN CWI_BudgetMonthClassification BMC ON BMC.BudgetMonthID = BM.ID
		WHERE  DB.ClientBudgetID = @ClientBudgetId AND DB.DivisionID = @DivisionId
		AND BM.Month = Month(@BudgetDate) AND BM.Year = Year(@BudgetDate)
		AND BMC.ClassificationLookupID = @ClassifciationId
		print @BudgetMonthClassificationID
		IF @BudgetMonthClassificationID IS NOT NULL
		begin
			SELECT 

				ISNULL(BMCV.Id,0) Id,
				(VendorCode+''-''+VendorName) DisplayName,
				CAST(ISNULL(BMCV.BudgetAvailable,0) as decimal(18,2)) BudgetAvailable,
	 			CAST(ISNULL(BMCV.BudgetForecast,0)	as decimal(18,2)) BudgetForecast,
				CAST(ISNULL(BMCV.BudgetUsed,0) AS decimal(18,2)) BudgetUsed,
				CAST(ISNULL(BMCV.BudgetCommitted,0) AS decimal(18,2)) BudgetCommitted,
				cast(VendorID AS VARCHAR(10)) Unavailable,
				 ''V'' [Level],
				CAST(@ClassifciationId as varchar(10)) ParentKey,
				--''V''+CAST(V.ID AS VARCHAR(10)) DataKey,
				CAST(V.ID AS VARCHAR(10)) DataKey,
				BMC.ID as BudgetMonthClassificationID
			FROM CWI_BudgetMonthClassVendor BMCV
			INNER JOIN  CWI_Vendor V
				ON V.ID = BMCV.VendorID
				INNER JOIN CWI_BudgetMonthClassification BMC
				ON bmc.ID=BMCV.BudgetMonthClassificationID
			WHERE BudgetMonthClassificationID =  @BudgetMonthClassificationID
		END
	end
	
	ELSE IF @SearchFor=''I''
	begin		
		SET @BudgetMonthClassificationID = NULL

		SELECT top 1 @BudgetMonthClassificationID =BMC.ID  FROM CWI_DivisionBudget DB
		INNER JOIN CWI_ClientBudget CB ON CB.Id = DB.ClientBudgetID
		INNER JOIN CWI_BudgetMonth BM ON BM.DivisionBudgetID = DB.ID
		INNER JOIN CWI_BudgetMonthClassification BMC ON BMC.BudgetMonthID = BM.ID
		WHERE  DB.ClientBudgetID = @ClientBudgetId AND DB.DivisionID = @DivisionId
		AND BM.Month = Month(@BudgetDate) AND BM.Year = Year(@BudgetDate)
		AND BMC.ClassificationLookupID = @ClassifciationId
		print @BudgetMonthClassificationID
		IF @BudgetMonthInvoiceId IS NOT NULL
		begin
			SELECT 

				ISNULL(BMCV.Id,0) Id,
				CONVERT(varchar,InvoiceDate,101) DisplayName,
				CAST(ISNULL(BMCV.BudgetAvailable,0) as decimal(18,2)) BudgetAvailable,
	 			CAST(ISNULL(BMCV.BudgetForecast,0)	as decimal(18,2)) BudgetForecast,
				CAST(ISNULL(BMCV.BudgetUsed,0) AS decimal(18,2)) BudgetUsed,
				CAST(ISNULL(BMCV.BudgetCommitted,0) AS decimal(18,2)) BudgetCommitted,
				cast(BM.ID AS VARCHAR(10)) Unavailable,
				 ''I'' [Level],
				CAST(@ClassifciationId as varchar(10)) ParentKey,
				--''V''+CAST(V.ID AS VARCHAR(10)) DataKey,
				CAST(BMCV.ID AS VARCHAR(10)) DataKey,
				BMC.ID as BudgetMonthClassificationID
			FROM CWI_BudgetMonthInvoice BMCV
			INNER JOIN  CWI_BudgetMonth BM
				ON BM.ID = BMCV.BudgetMonthID
				INNER JOIN CWI_BudgetMonthClassification BMC
				ON bmc.ID=BMCV.ClassificationLookupID
			WHERE BMCV.ClassificationLookupID =  @BudgetMonthInvoiceId
		END
	end

	ELSE IF @SearchFor=''IV''
	begin		
		
		
		IF @BudgetMonthInvoiceID IS NOT NULL
		begin
			SELECT 

				ISNULL(BMIV.Id,0) Id,
				(VendorCode+''-''+VendorName) DisplayName,
				CAST(ISNULL(BMIV.BudgetAvailable,0) as decimal(18,2)) BudgetAvailable,
	 			CAST(ISNULL(BMIV.BudgetForecast,0)	as decimal(18,2)) BudgetForecast,
				CAST(ISNULL(BMIV.BudgetUsed,0) AS decimal(18,2)) BudgetUsed,
				CAST(ISNULL(BMIV.BudgetCommitted,0) AS decimal(18,2)) BudgetCommitted,
				cast(V.ID AS VARCHAR(10)) Unavailable,
				 ''IV'' [Level],
				CAST(BMI.ID as varchar(10)) ParentKey,				
				CAST(V.ID AS VARCHAR(10)) DataKey,
				BMI.ID as BudgetMonthClassificationID
			FROM CWI_BudgetMonthInvoiceVendor BMIV			
			INNER JOIN CWI_BudgetMonthInvoice BMI ON	BMI.ID=BMIV.BudgetMonthInvoiceID
			INNER JOIN CWI_Vendor V ON	V.ID=BMIV.VendorID
			INNER JOIN  CWI_BudgetMonth BM ON BM.ID = BMI.BudgetMonthID
			INNER JOIN CWI_BudgetMonthClassification BMC ON bmc.ID=BMI.ClassificationLookupID
			WHERE BMC.ClassificationLookupID =  @ClassifciationId AND BMI.ID=@BudgetMonthInvoiceId;
		END
	end
END	


' 
END
GO
