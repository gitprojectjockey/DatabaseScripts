
--Get second highest balance
select max(balance) from 
[Accounts]
where balance < (select max(balance) from [Accounts])

--Get nth highest balance (This is getting the sixth hightest balance)
select top 1 balance from 
(select distinct top 6 balance from Accounts 
order by balance desc)
Results
order by balance

GO
--Get nth highest balance using a CTE table (Common Table Expression) (This is getting the sixth hightest balance)
WITH Result as
--Create the table expression--
(
	select balance , DENSE_RANK() over (order by balance desc) as 'DenseRank'
	from Accounts
)
--Now Query the CTE--
select balance from Result
where Result.DenseRank = 6
