/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorStatus]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorStatus]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorStatus]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_SetVendorStatus]
(
	@VendorId	int,
	@StatusId	int
)
AS
BEGIN
	UPDATE  CWI_Vendor SET StatusLookupId = @StatusId
	WHERE ID = @VendorId
END' 
END
GO
