/****** Object:  Trigger [CWI_TR_COMDATAReconcile_Insert]    Script Date: 11/12/2014 2:04:46 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_COMDATAReconcile_Insert]'))
DROP TRIGGER [dbo].[CWI_TR_COMDATAReconcile_Insert]
GO

/****** Object:  Trigger [dbo].[CWI_TR_COMDATAReconcile_Insert]    Script Date: 11/12/2014 2:04:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_COMDATAReconcile_Insert]'))
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohankumar Sundaram
-- Create date: 12NOV14
-- Description:	when  virtual card related transactions happen, evaluate the vitual card status 
-- =============================================
CREATE TRIGGER [dbo].[CWI_TR_COMDATAReconcile_Insert]
   ON  [dbo].[COMDATAReconcile] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @CCNumber varchar(50)

    SELECT top 1 @CCNumber = i.CardNO from  inserted i
	
	execute VCM_UpdateAPStatus @CCNumber
END
' 
GO


