/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteTaskAttachment]    Script Date: 11/26/2013 3:28:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteTaskAttachment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_DeleteTaskAttachment]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_DeleteTaskAttachment]    Script Date: 11/26/2013 3:28:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_DeleteTaskAttachment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_DeleteTaskAttachment]
	@id int,
	@RowCount int output
AS
BEGIN
	BEGIN TRY
		UPDATE CWI_TaskAttachment SET IsRemoved = 1
		WHERE Id = @id
		SET @RowCount = (SELECT @@ROWCOUNT as RowAffected)
	END TRY
	BEGIN CATCH
		EXEC PRC_CWI_APPRAISEERROR; 
		THROW;
	END CATCH
END 

' 
END
GO
