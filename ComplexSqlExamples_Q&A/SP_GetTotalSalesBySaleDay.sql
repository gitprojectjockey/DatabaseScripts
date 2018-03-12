
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'GetTotalSalesBySaleDay', 'P') IS NOT NULL
	DROP PROCEDURE GetTotalSalesBySaleDay
GO


CREATE PROCEDURE GetTotalSalesBySaleDay 
	@SaleDate date,
	@EmployeeId int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @EmployeeId IS NULL
		BEGIN
			Select e.LastName, SUM(es.SaleAmount) as TotalSales 
			from  Employee e
			inner join EmployeeSales es
			on e.EmployeeId = es.EmployeeId
			where CONVERT(DATE, es.SaleDate, 101) =  @SaleDate 
			--and es.EmployeeId = 0
			group by e.LastName
		END
	ELSE
	BEGIN
			Select e.LastName, SUM(es.SaleAmount) as TotalSales 
			from  Employee e
			inner join EmployeeSales es
			on e.EmployeeId = es.EmployeeId
			where CONVERT(DATE, es.SaleDate, 101) =  @SaleDate 
			and es.EmployeeId = @EmployeeId
			group by e.LastName
	END
END
GO
