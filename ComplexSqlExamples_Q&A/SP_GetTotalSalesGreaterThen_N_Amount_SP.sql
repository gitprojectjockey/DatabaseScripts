SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'GetTotalSalesGreaterThen_N_Amount', 'P') IS NOT NULL
	DROP PROCEDURE GetTotalSalesGreaterThen_N_Amount
GO

CREATE PROCEDURE GetTotalSalesGreaterThen_N_Amount
	@amount int = 0
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Select e.LastName, SUM(es.SaleAmount) as TotalSales 
	from  Employee e
	inner join EmployeeSales es
	on e.EmployeeId = es.EmployeeId
	where es.SaleDate > getdate()
	Group By e.EmployeeId, e.LastName
	Having Sum(es.SaleAmount) >= @amount
END

