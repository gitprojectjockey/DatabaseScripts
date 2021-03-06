/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHoliday]    Script Date: 9/25/2014 8:31:46 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHoliday]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetHoliday]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetHoliday]    Script Date: 9/25/2014 8:31:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetHoliday]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/**************************************************************************************************

* PROCEDURE: [prc_CWI_GetHoliday]

* Purpose : This Proc would be called to get the holiday list in the Job Summary details page

* Invoked from : Jobs.aspx

* CREATED: Bala

* MODIFICATION HISTORY  

* DATE      AUTHOR          DESCRIPTION              



**********************************************************************  

Execution example :

********************************************************************** 

exec [prc_CWI_GetHoliday] 

**********************************************************************/ 

 --prc_CWI_GetHoliday ''2014-11-27''
CREATE PROCEDURE [dbo].[prc_CWI_GetHoliday] (@StartDate Date)
AS
BEGIN
	BEGIN TRY
		DECLARE @enddate Date;
		SET @enddate = DATEADD(day,300,@StartDate)

		SELECT * FROM [dbo].Holiday WHERE HolidayDate BETWEEN @StartDate AND @enddate ORDER BY HolidayDate
	END TRY
	BEGIN CATCH	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH


	


END

	

	


' 
END
GO
