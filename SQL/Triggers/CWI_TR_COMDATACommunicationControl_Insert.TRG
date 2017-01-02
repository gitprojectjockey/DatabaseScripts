/****** Object:  Trigger [CWI_TR_COMDATACommunicationControl_Insert]    Script Date: 11/5/2014 3:38:47 PM ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_COMDATACommunicationControl_Insert]'))
DROP TRIGGER [dbo].[CWI_TR_COMDATACommunicationControl_Insert]
GO

/****** Object:  Trigger [dbo].[CWI_TR_COMDATACommunicationControl_Insert]    Script Date: 11/5/2014 3:38:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[CWI_TR_COMDATACommunicationControl_Insert]'))
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		Mohankumar Sundaram
-- Create date: 05NOV14
-- Description:	when inserting virtual card request/update, evaluate the vitual card status 
-- =============================================
CREATE TRIGGER [dbo].[CWI_TR_COMDATACommunicationControl_Insert]
   ON  [dbo].[COMDATACommunicationControl] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @CCNumber varchar(50),
		@mediabuyId bigint
    SELECT top 1 @mediabuyId = i.SettlementID from  inserted i

	SELECT top 1 @CCNumber = CCNumber FROM SettlementComDataCCNumber WHERE SettlementID = @mediabuyId
	execute VCM_UpdateAPStatus @CCNumber
END
' 
GO


