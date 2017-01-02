BEGIN TRY

BEGIN TRANSACTION 

/* LookupType */
INSERT [dbo].[LookupType] ([Id], [LookupTypeName], [RangeStarting], [RangeEnding], [CreatedBy], [CreatedOn]) VALUES (55, N'Message Type', 22250, 22260, N'oss\srajamani', GetDate()))

/* Lookup */
INSERT [dbo].[Lookup] ([Id], [LookupTypeId], [LookupName], [SortOrder], [IsActive], [IsSystemGenerated], [CreatedBy], [CreatedOn]) VALUES (22250, 55, N'Advertisement Approval', 0, 1, 0, N'oss\srajamani', GetDate()))

COMMIT TRAN -- Transaction Success!

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
	ROLLBACK TRAN 

    DECLARE @ErrorNumber INT = ERROR_NUMBER()
    DECLARE @ErrorLine INT = ERROR_LINE()
	DECLARE @ErrorMessage VARCHAR(MAX) = ERROR_MESSAGE()

    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10))
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10))
	PRINT 'Actual error message: ' + @ErrorMessage

    --THROW @ErroNumber,@ErrorMessage,1;

END CATCH
GO
