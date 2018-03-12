USE Interview;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('UpdateEmployeeSaleAmount','P') IS NOT NULL
	DROP PROCEDURE UpdateEmployeeSaleAmount 
GO

CREATE PROCEDURE UpdateEmployeeSaleAmount
	@EmployeeSaleId int, 
	@EmployeeId int,
	@SalesAmt decimal(16,2) = 0.00
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE EmployeeSales Set SaleAmount = @SalesAmt
			WHERE EmployeeId = @EmployeeId
			AND EmployeeSales.EmployeeSaleId = @EmployeeSaleId

			UPDATE Employee Set LastSalesAmtUpdate = GETDATE()
			WHERE EmployeeId = @EmployeeId
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
