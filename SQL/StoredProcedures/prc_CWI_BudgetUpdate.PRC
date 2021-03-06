/****** Object:  StoredProcedure [dbo].[prc_CWI_BudgetUpdate]    Script Date: 6/17/2014 6:21:57 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_BudgetUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_BudgetUpdate]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_BudgetUpdate]    Script Date: 6/17/2014 6:21:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_BudgetUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/****************************************************************************************
* PROCEDURE: prc_CWI_BudgetUpdate
* Purpose : This Proc will be called to update Client/division budget from job and service tables
* Invoked from : SQL Job
* CREATED: Saravanan 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION
  23MAY14	Mohankumar		Service budget updated  
**********************************************************************  
*/

CREATE PROCEDURE [dbo].[prc_CWI_BudgetUpdate]
	@cutoffMonths int = 3
AS
BEGIN


DECLARE @dt datetime = getdate()
	DECLARE @tblVendor TABLE(
		DivisionBudgetId int,
		DivisionId int,
		InvoiceStartDate datetime,
		VendorId INT,
		ClassificationId INT,
		[Committed] DECIMAL,
		Used DECIMAL
       
	)
	DECLARE @tblJobService TABLE(
		DivisionBudgetId int,
		DivisionId int,
		InvoiceStartDate datetime,
		ServiceId INT,
		[Committed] DECIMAL,
		Used DECIMAL
	)

	DECLARE @tblVendorFull TABLE(
		ClientBudgetId int,
		DivisionBudgetId int,
		BudgetMonthId int,
		BudgetMonthClassId int,
		DivisionId int,
		InvoiceStartDate datetime,
		VendorId INT,
		ClassificationId INT,
		[Committed] DECIMAL,
		Used DECIMAL
       
	)
	DECLARE @tblJobServiceFull TABLE(
		ClientBudgetId int,
		DivisionBudgetId int,
		BudgetMonthId int,
		BudgetMonthServiceId int,
		DivisionId int,
		InvoiceStartDate datetime,
		ServiceId INT,
		[Committed] DECIMAL,
		Used DECIMAL
	)

	declare @dtCutoff datetime = DATEADD(m,-1 * @cutoffMonths, getdate())
	set @dtCutoff = DATEADD(d,-day(@dtCutoff) +1, @dtCutoff)

	/*  Get the cost details at media buy level and keep in table variable */
	INSERT INTO @tblVendor
	SELECT
		DB.Id, 
		J.DivisionId,dateadd(d,-day(InvoiceDate)+1,j.InvoiceDate) InvoiceStartDate,
		JMB.VendorId,
		J.ClassificationId,
		CASE WHEN JMB.DNR=1 OR JMB.IsCancelled = 1 OR JMB.IsRemoved = 1 THEN 0
			ELSE 
				CASE WHEN InvoiceGeneratedDate IS NULL THEN ISNULL(ActualInvoice,0) ELSE 0 END
		END Commited,  
		CASE WHEN JMB.DNR=1 OR JMB.IsCancelled = 1 OR JMB.IsRemoved = 1 THEN 0
			ELSE
				CASE WHEN InvoiceGeneratedDate IS NULL THEN 0 ELSE ISNULL(ActualInvoice,0) END 
		END Used
	FROM CWI_Job J
		   INNER JOIN CWI_JobMediaBuy JMB
				  ON J.Id = JMB.JobId
			INNER JOIN CWI_DivisionBudget DB
				  ON DB.DivisionID = J.DivisionId
	WHERE
		   J.InvoiceDate >= @dtCutoff
		   AND J.InvoiceDate >= DB.BudgetFrom
		   AND J.InvoiceDate <= DB.BudgetTo
		  
	/*  Get the cost details at service fee level and keep in table variable */
	INSERT INTO @tblJobService
	SELECT
		s.DivBudgetId, s.DivisionId,s.InvoiceStartDate, s.ServiceId,
		SUM(Commited) Commited,
		SUM(Used) Used
	FROM
	(
	SELECT 
		DB.Id DivBudgetId,
		J.DivisionId,
		dateadd(d,-day(InvoiceDate)+1,j.InvoiceDate) InvoiceStartDate,
		JS.ServiceId,  
		CASE WHEN JS.IsDeleted = 1 THEN 1
			ELSE
				CASE WHEN J.InvoiceId IS NULL THEN ServiceFee ELSE 0 END 
		END Commited,  
		CASE WHEN JS.IsDeleted = 1 THEN 1
			ELSE
				CASE WHEN J.InvoiceId IS NULL THEN 0 ELSE ServiceFee END 
		END Used
	FROM CWI_Job J
		   INNER JOIN CWI_JobService JS
				  ON J.Id = JS.JobId
		  INNER JOIN CWI_DivisionBudget DB
				  ON DB.DivisionID = J.DivisionId
				  
	WHERE
		   J.InvoiceDate >= @dtCutoff
		   AND J.InvoiceDate >= DB.BudgetFrom
		   AND J.InvoiceDate <= DB.BudgetTo
		   AND JS.ServiceId IS NOT NULL
	) s
	GROUP By s.DivBudgetId, s.DivisionId,s.InvoiceStartDate, s.ServiceId

	/*  Insert into budget month table if months of media buy are not created for budget*/
	INSERT INTO CWI_BudgetMonth
	(
		DivisionBudgetID,
		Month,
		Year,
		BudgetForecast,
		BudgetUsed,
		BudgetCommitted,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn
		)

	SELECT distinct t.DivisionBudgetId, MONTH(t.InvoiceStartDate), YEAR(t.InvoiceStartDate), 
		0,0,0,
		1, @dt, 1,@dt
	FROM @tblVendor t
		LEFT OUTER JOIN CWI_BudgetMonth BM
			ON BM.DivisionBudgetID = t.DivisionBudgetId
			AND BM.BudgetMonthStartDate = t.InvoiceStartDate
	WHERE
		BM.Id IS NULL

	/*  Insert into budget month table if months of service fee are not created for budget*/
	INSERT INTO CWI_BudgetMonth
	(
		DivisionBudgetID,
		Month,
		Year,
		BudgetForecast,
		BudgetUsed,
		BudgetCommitted,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn
		)

	SELECT distinct t.DivisionBudgetId, MONTH(t.InvoiceStartDate), YEAR(t.InvoiceStartDate), 
		0,0,0,
		1, @dt, 1,@dt
	FROM @tblJobService t
		LEFT OUTER JOIN CWI_BudgetMonth BM
			ON BM.DivisionBudgetID = t.DivisionBudgetId
			AND BM.BudgetMonthStartDate = t.InvoiceStartDate
	WHERE
		BM.Id IS NULL


	/*  Insert into budget month classification table if classifications are not created for budget*/
	INSERT INTO CWI_BudgetMonthClassification
	(
		BudgetMonthId,
		ClassificationLookupID,
		BudgetForecast,
		BudgetUsed,
		BudgetCommitted,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn
		)

	SELECT distinct BM.Id,t.ClassificationId, 
		0,0,0,
		1, @dt, 1,@dt
	FROM @tblVendor t
		INNER JOIN CWI_BudgetMonth BM
			ON BM.DivisionBudgetID = t.DivisionBudgetId
			AND BM.BudgetMonthStartDate = t.InvoiceStartDate
		LEFT OUTER JOIN CWI_BudgetMonthClassification BMC
			ON BMC.BudgetMonthId = Bm.ID
			AND BMC.ClassificationLookupID = t.ClassificationId
	WHERE
		BMC.Id IS NULL


	/*  Insert into budget month service table if service fees are not created for budget*/
	INSERT INTO CWI_BudgetMonthService
	(
		BudgetMonthId,
		ServiceID,
		BudgetForecast,
		BudgetUsed,
		BudgetCommitted,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn
		)

	SELECT distinct BM.Id,t.ServiceId, 
		0,0,0,
		1, @dt, 1,@dt
	FROM @tblJobService t
		INNER JOIN CWI_BudgetMonth BM
			ON BM.DivisionBudgetID = t.DivisionBudgetId
			AND BM.BudgetMonthStartDate = t.InvoiceStartDate
		LEFT OUTER JOIN CWI_BudgetMonthService BMS
			ON BMS.BudgetMonthId = Bm.ID
			AND BMS.ServiceID = t.ServiceId
	WHERE
		BMS.Id IS NULL

	/*  Update budget month classification vendor table for media buy level costs*/
	UPDATE CWI_BudgetMonthClassVendor SET BudgetUsed= t.Used, BudgetCommitted= t.Committed
	FROM  @tblVendor t
		INNER JOIN CWI_BudgetMonth BM
			ON BM.DivisionBudgetID = t.DivisionBudgetId
			AND BM.BudgetMonthStartDate = t.InvoiceStartDate
		INNER JOIN CWI_BudgetMonthClassification BMC
			ON BMC.BudgetMonthId = Bm.ID
			AND BMC.ClassificationLookupID = t.ClassificationId
		INNER JOIN CWI_BudgetMonthClassVendor BMCV
			ON BMCV.BudgetMonthClassificationID = BMC.Id
			AND BMCV.VendorID = t.VendorId
	
	INSERT INTO @tblVendorFull
	(
		ClientBudgetId ,
		DivisionBudgetId ,
		BudgetMonthId ,
		BudgetMonthClassId ,
		DivisionId ,
		InvoiceStartDate ,
		VendorId ,
		ClassificationId ,
		[Committed] ,
		Used 
	)
	SELECT 
		CB.Id,
		DB.Id,
		BM.Id,
		BMC.ID,
		t.DivisionId,
		t.InvoiceStartDate,
		t.VendorId,
		t.ClassificationId,
		t.Committed,
		t.Used
	FROM @tblVendor t
	INNER JOIN CWI_BudgetMonth BM
		ON BM.DivisionBudgetID = t.DivisionBudgetId
		AND BM.BudgetMonthStartDate = t.InvoiceStartDate
	INNER JOIN CWI_BudgetMonthClassification BMC
		ON BMC.BudgetMonthId = Bm.ID
		AND BMC.ClassificationLookupID = t.ClassificationId
	INNER JOIN CWI_DivisionBudget DB
		ON DB.Id = t.DivisionBudgetId
	INNER JOIN CWI_ClientBudget CB
		ON CB.Id = DB.ClientBudgetID

	INSERT INTO @tblJobServiceFull
	(
		ClientBudgetId ,
		DivisionBudgetId ,
		BudgetMonthId ,
		BudgetMonthServiceId ,
		DivisionId ,
		InvoiceStartDate ,
		ServiceId ,
		[Committed] ,
		Used 
	)
	SELECT 
		CB.Id,
		DB.Id,
		BM.Id,
		BMS.ID,
		t.DivisionId,
		t.InvoiceStartDate,
		t.ServiceId,
		t.Committed,
		t.Used
	FROM @tblJobService t
	INNER JOIN CWI_BudgetMonth BM
		ON BM.DivisionBudgetID = t.DivisionBudgetId
		AND BM.BudgetMonthStartDate = t.InvoiceStartDate
	INNER JOIN CWI_BudgetMonthService BMS
		ON BMS.BudgetMonthId = Bm.ID
		AND BMS.ServiceID = t.ServiceId
	INNER JOIN CWI_DivisionBudget DB
		ON DB.Id = t.DivisionBudgetId
	INNER JOIN CWI_ClientBudget CB
		ON CB.Id = DB.ClientBudgetID



	/*  Update budget month classification table for media buy level costs*/
	UPDATE CWI_BudgetMonthClassification SET BudgetUsed= t.Used, BudgetCommitted= t.Committed
	FROM 
	( 
		SELECT BudgetMonthClassId , SUM(Used) Used, SUM(Committed) Committed
		FROM @tblVendorFull
		GROUP BY BudgetMonthClassId ) t
	WHERE
		Id  = BudgetMonthClassId
		
		/*  Update budget month service table for service fees*/
	UPDATE CWI_BudgetMonthService SET BudgetUsed= t.Used, BudgetCommitted= t.Committed
	FROM 
	( 
		SELECT BudgetMonthServiceId , SUM(Used) Used, SUM(Committed) Committed
		FROM @tblJobServiceFull
		GROUP BY BudgetMonthServiceId ) t
	WHERE
		Id  = BudgetMonthServiceId


	DECLARE @tblSummary TABLE
	( 
	ClientBudgetId int,
	DivisionBudgetId int,
	BudgetMonthId int,
	[Committed]  decimal ,
	Used decimal
	)

	INSERT INTO @tblSummary
   SELECT ClientBudgetId ,
		DivisionBudgetId ,
		BudgetMonthId, SUM([Committed])  [Committed], SUM(Used) Used FROM
   (
	SELECT ClientBudgetId ,
		DivisionBudgetId ,
		BudgetMonthId ,
		[Committed] [Committed],
		Used Used  FROM @tblJobServiceFull
		
	 
	UNION ALL
	 SELECT ClientBudgetId ,
		DivisionBudgetId ,
		BudgetMonthId ,
		[Committed] ,
		Used Used  FROM @tblVendorFull
		) t 
	GROUP BY ClientBudgetId ,
		DivisionBudgetId ,
		BudgetMonthId
		

		/*  Update budget month table for service fees and media buy costs*/
	UPDATE CWI_BudgetMonth  SET BudgetUsed= t.Used, BudgetCommitted= t.Committed
	FROM 
	( 
		SELECT BudgetMonthId , SUM(Used) Used, SUM(Committed) Committed
		FROM @tblSummary
		GROUP BY BudgetMonthId ) t
	WHERE
		Id  = BudgetMonthId

	/*  Update division budget month table for service fees and media buy costs*/
	UPDATE CWI_DivisionBudget  SET BudgetUsed= t.Used, BudgetCommitted= t.Committed
	FROM 
	( 
		SELECT DivisionBudgetId  , SUM(Used) Used, SUM(Committed) Committed
		FROM @tblSummary
		GROUP BY DivisionBudgetId  ) t
	WHERE
		Id  = DivisionBudgetId 


	/************************ Division Budget********************************************************/

	UPDATE CWI_DivisionBudget 
	SET 
		BudgetUsed=ISNUll(X.BudgetUsed,0.00),
		BudgetCommitted=ISNUll(X.BudgetCommitted,0.00)
	FROM CWI_DivisionBudget DB1
		INNER JOIN
		(
		select BM.DivisionBudgetID,
			 SUM(BM.BudgetForecast) BudgetForecast,
			 SUM(BM.BudgetUsed) BudgetUsed,
			 SUM(BM.BudgetCommitted) BudgetCommitted from  CWI_DivisionBudget DB
		Inner Join CWI_BudgetMonth BM ON BM.DivisionBudgetID=DB.ID 
		INNER JOIN (SELECT distinct DivisionBudgetId FROM @tblSummary) t
			ON t.DivisionBudgetId = DB.Id
		group by BM.DivisionBudgetID
		)X ON X.DivisionBudgetID=DB1.id

	/************************ Client Budget********************************************************/
	UPDATE CWI_ClientBudget 
	SET 
		BudgetUsed=ISNUll(X.BudgetUsed,0.00),
		BudgetCommitted=ISNUll(X.BudgetCommitted,0.00)
	FROM CWI_ClientBudget CB1
		INNER JOIN
		(
		select DB.ClientBudgetID,
				SUM(DB.BudgetUsed) BudgetUsed,
				SUM(DB.BudgetCommitted) BudgetCommitted 
		from  CWI_ClientBudget CB
		Inner Join CWI_DivisionBudget DB ON DB.ClientBudgetID=CB.ID 
		INNER JOIN (SELECT distinct ClientBudgetId  FROM @tblSummary) t
			ON t.ClientBudgetId  = CB.Id
		group by DB.ClientBudgetID
		)X ON X.ClientBudgetID=CB1.id

END

' 
END
GO
