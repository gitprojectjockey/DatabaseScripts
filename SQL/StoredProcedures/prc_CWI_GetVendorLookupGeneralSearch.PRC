/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorLookupGeneralSearch]    Script Date: 12/20/2013 5:14:49 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorLookupGeneralSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetVendorLookupGeneralSearch]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_GetVendorLookupGeneralSearch]    Script Date: 12/20/2013 5:14:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetVendorLookupGeneralSearch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_GetVendorLookupGeneralSearch
* Purpose : This PROC would be called TO search vendors by general criteria
* Invoked from : VendorLookup.aspx  
* CREATED: MohanKumar SUndaram
* CREATED ON : 27May2013
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
26Jun2014   Vijesh			Returns ClientLastUsedOn column, Added DivisionId as parameter    

**********************************************************************  
Execution example :
**********************************************************************  
prc_CWI_GetVendorLookupGeneralSearch @VendorIds='''', @VendorCode = '''', @VendorName = '''', @Classifications = '''', @States = '''', @Cities = ''ANNISTON'', @LastUsed = 100, @LastUsedOption = ''D''
**********************************************************************/ 


CREATE PROC [dbo].[prc_CWI_GetVendorLookupGeneralSearch]
	@VendorIds varchar(max) =NULL,
	@VendorCode varchar(100),
	@VendorName varchar(200),
	@Classifications varchar(max) = '''',
	@States	varchar(max),
	@Cities varchar(max),
	@LastUsed	int,
	@LastUsedOption	varchar(1),
	@DivisionId int=NULL

AS
BEGIN
DECLARE @tblVendor TABLE
	(
		VendorId int,
		VendorCode varchar(50),
		VendorName varchar(200),
		LastUsedOn datetime,
		Circulation int,
		Physical_StateName varchar(50),
		Physical_City varchar(50),
		ClassId int,
		Physical_StateId int,
		ClientLastUsedOn datetime
		
	)

	IF @VendorIds IS NOT NULL AND ISNULL(@VendorIds,'''') <> ''''
	BEGIN
		
		DECLARE @tblVendorId TABLE
		(VendorId int)
		INSERT INTO @tblVendorId
			SELECT CAST(Items as int) FROM dbo.fnc_utl_Split(@VendorIds,'','')

			INSERT INTO @tblVendor
			select 
				V.VendorId,
				VendorCode,
				VendorName ,
				LastUsedOn,
				Circulation,
				Physical_StateName,
				Physical_City,
				ClassificationLookupId,
				Physical_StateId
				,ClientLastUsedOn

			from vw_CWI_VendorAddress VA
			INNER JOIN  @tblVendorId V
				ON VA.VendorId = V.VendorId
			left outer join (
				select mb.VendorId,max(mb.CreatedOn) as ClientLastUsedOn from cwi_job j inner join CWI_JobMediaBuy mb
				on j.ID=mb.JobId and j.DivisionId=@DivisionId
				group by mb.VendorId
			)x
			on x.VendorId=VA.VendorId
			
			SELECT 
				VendorId,
				VendorCode,
				VendorName ,
				LastUsedOn,
				Circulation,
				Physical_StateName,
				Physical_City
				,ClientLastUsedOn
			FROM @tblVendor
		RETURN
	END

	DECLARE @dtLastUsed date
	SET @dtLastUsed = NULL

	IF @VendorCode = '''' SET @VendorCode = NULL
	IF @VendorName = '''' SET @VendorName = NULL
	IF @LastUsed>0 
	BEGIN
		IF @LastUsedOption = ''D'' 
			SELECT @dtLastUsed = dateadd(day,-1 *@LastUsed , cast(getdate() as date));
		ELSE IF @LastUsedOption = ''M'' 
			SELECT @dtLastUsed = dateadd(month,-1*@LastUsed, cast(getdate() as date))
		ELSE IF @LastUsedOption = ''W'' 
			SELECT @dtLastUsed = dateadd(WEEK,-1*@LastUsed, cast(getdate() as date))

	END

	
	DECLARE @tblState TABLE
	(StateId int)

	DECLARE @tblCity TABLE
	(City varchar(100))

	DECLARE @tblClassification TABLE
	(ClassId int)
	
	IF @Classifications <> ''''
	BEGIN
		INSERT INTO @tblClassification
			SELECT CAST(Items as int) FROM dbo.fnc_utl_Split(@Classifications,'','')

		INSERT INTO @tblVendor
		select 
				VA.VendorId,
				VendorCode,
				VendorName ,
				LastUsedOn,
				Circulation,
				Physical_StateName,
				Physical_City,
				ClassificationLookupId,
				Physical_StateId,
				NULL as ClientLastUsedOn				

			from vw_CWI_VendorAddress VA
			INNER JOIN  @tblClassification C
				ON VA.ClassificationLookupId = C.ClassId	
			WHERE VA.statuslookupid = 		552 -- Active
			AND VA.IsDeleted = 0
	END
	ELSE
	BEGIN
		INSERT INTO @tblVendor
			select 
				VA.VendorId,
				VendorCode,
				VendorName ,
				LastUsedOn,
				Circulation,
				Physical_StateName,
				Physical_City,
				ClassificationLookupId,
				Physical_StateId
				,ClientLastUsedOn
			from vw_CWI_VendorAddress VA

			left outer join (
				select mb.VendorId,max(mb.CreatedOn) as ClientLastUsedOn from cwi_job j inner join CWI_JobMediaBuy mb
				on j.ID=mb.JobId and j.DivisionId=@DivisionId
				group by mb.VendorId
			)x
			on x.VendorId=VA.VendorId

			WHERE VA.statuslookupid = 		552 -- Active
				AND VA.IsDeleted = 0
	END


	IF @States <> '''' OR @Cities<> ''''
	BEGIN
		IF @States <> '''' AND @Cities <> ''''
		Begin
			INSERT INTO @tblState
			SELECT CAST(Items as int) FROM dbo.fnc_utl_Split(@States,'','')

			INSERT INTO @tblCity
			SELECT Items  FROM dbo.fnc_utl_Split(@Cities,'','')

			select 
				VendorId,
				VendorCode,
				VendorName ,
				LastUsedOn,
				Circulation,
				Physical_StateName,
				Physical_City,
				ClientLastUsedOn

			from @tblVendor VA
			INNER JOIN  @tblState S
				ON VA.Physical_StateId = S.StateId
			INNER JOIN  @tblCity C
				ON VA.Physical_City = C.City



			WHERE
				(VendorCode like  @VendorCode + ''%'' OR @VendorCode IS NULL)
				AND (VendorName like  @VendorName + ''%'' OR @VendorName IS NULL)
				  AND  (LastUsedOn >= @dtLastUsed OR @dtLastUsed IS NULL)
		  
			ORDER BY VendorCode
		End					
		IF @States <> '''' 
		Begin
			INSERT INTO @tblState
			SELECT CAST(Items as int) FROM dbo.fnc_utl_Split(@States,'','')

			select 
				VendorId,
				VendorCode,
				VendorName ,
				LastUsedOn,
				Circulation,
				Physical_StateName,
				Physical_City,
				ClientLastUsedOn

			from @tblVendor VA
			INNER JOIN  @tblState S
				ON VA.Physical_StateId = S.StateId

			WHERE
				(VendorCode like  @VendorCode + ''%'' OR @VendorCode IS NULL)
				AND (VendorName like  @VendorName + ''%'' OR @VendorName IS NULL)
				  AND  (LastUsedOn >= @dtLastUsed OR @dtLastUsed IS NULL)
		  
			ORDER BY VendorCode

		End
		IF @Cities <> ''''
		Begin
			INSERT INTO @tblCity
			SELECT Items  FROM dbo.fnc_utl_Split(@Cities,'','')

			select 
				VendorId,
				VendorCode,
				VendorName ,
				LastUsedOn,
				Circulation,
				Physical_StateName,
				Physical_City,
				ClientLastUsedOn

			from @tblVendor VA
			INNER JOIN  @tblCity C
				ON VA.Physical_City = C.City

			WHERE
				(VendorCode like  @VendorCode + ''%'' OR @VendorCode IS NULL)
				AND (VendorName like  @VendorName + ''%'' OR @VendorName IS NULL)
				  AND  (LastUsedOn >= @dtLastUsed OR @dtLastUsed IS NULL)
		  
			ORDER BY VendorCode

		End

	END
	ELSE
	BEGIN
		select 
			VendorId,
			VendorCode,
			VendorName ,
			LastUsedOn,
			Circulation,
			Physical_StateName,
			Physical_City,
			ClientLastUsedOn

		from @tblVendor
		WHERE
			(VendorCode like  @VendorCode + ''%'' OR @VendorCode IS NULL)
			AND (VendorName like  @VendorName + ''%'' OR @VendorName IS NULL)
			  AND  (LastUsedOn >= @dtLastUsed OR @dtLastUsed IS NULL)
		  
		ORDER BY VendorCode
	END
END





' 
END
GO


