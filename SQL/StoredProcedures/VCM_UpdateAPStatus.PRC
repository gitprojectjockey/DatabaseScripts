/****** Object:  StoredProcedure [dbo].[VCM_UpdateAPStatus]    Script Date: 11/5/2014 3:38:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VCM_UpdateAPStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[VCM_UpdateAPStatus]
GO

/****** Object:  StoredProcedure [dbo].[VCM_UpdateAPStatus]    Script Date: 11/5/2014 3:38:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VCM_UpdateAPStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
Author: Kevin Barlow
Date: December 20, 2004
Input: Credit Card Number
Output: Credit Card StatusID
Description: Evalutes the current status of a Credit Card to determine what Status Queue it should reside in.
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  04NOV14	Mohankumar		Changes for new clientwise tables
*/
CREATE             proc [dbo].[VCM_UpdateAPStatus] 
	(@CCNUMBER varchar(25))

AS 

declare
	@CURRENTSTATUS	as int,
	@SETTLEMENTID AS int

	DECLARE 
		@CREDITCARDREQUESTED int = 22141,
		@CREDITCARDLIMITUPDATED int = 22142,
		@AUTHORIZATIONINBALANCE int = 22143,
		@TRANSACTIONINBALANCE int = 22144,
		@AUTHORIZATIONSDECLINED int = 22171,
		@AUTHORIZATIONDECLINEDAFTERAPPROVAL int = 22172,
		@AUTHORIZATIONOUTOFBALANCE int = 22173,
		@TRANSACTIONOUTOFBALANCE int = 22174


Select @SETTLEMENTID = s.ID 
from CWI_JobMediaBuy s 
	Inner join SettlementComDataCCNumber scd on scd.SettlementID = s.ID
Where scd.CCNumber = @CCNUMBER

Select @CURRENTSTATUS = VCStatusLookupId 
from CWI_VCMediaBuy 
Where MediaBuyId = @SETTLEMENTID

---------------------------------------------------------------------------------------------------------
--OLD Settled In Balance (Status Type = 5)
--Transaction in Balance (Status Type = 22144)
if exists (Select top 1 ''x'' From CWI_JobMediaBuy s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Inner Join 
			ComDataReconcile cdr on
		scd.CCNumber = cdr.CardNo
		Where
			s.ID = @SETTLEMENTID
		and
			s.ActualCost = (Select sum(TotalAmt) from 
					(Select sum(totalAmountdue) as Totalamt from ComDataReconcile cdr2  
					where cdr2.Cardno = cdr.Cardno and cdr2.IsCredit = ''D'' 
					Union Select (sum(totalAmountDue) * -1) as TotalAmt 
					from ComDataReconcile cdr2 
					where Cdr2.CardNo = cdr.CardNo and cdr2.IsCredit = ''C'' 
					) as Temp)
		)

		BEGIN
			if @CURRENTSTATUS <> @TRANSACTIONINBALANCE  -- Status has Changed
				begin
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @TRANSACTIONINBALANCE,
						APReviewed = 0,
						APResolved = 1
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return
		END




---------------------------------------------------------------------------------------------------------
--OLD Settled In Balance - DNR or Cancelled (Status Type = 5)
--Transaction In Balance - DNR or Cancelled (Status Type = 22144)
if exists (Select top 1 ''x'' From CWI_JobMediaBuy s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Inner Join 
			ComDataReconcile cdr on
		scd.CCNumber = cdr.CardNo
		Where
			s.ID = @SETTLEMENTID
		and
			(s.dnr = 0 or s.IsCancelled = 0)
		and
			(Select sum(TotalAmt) from 
			(Select sum(totalAmountdue) as Totalamt from ComDataReconcile cdr2  
			where cdr2.Cardno = cdr.Cardno and cdr2.IsCredit = ''D'' 
			Union Select (sum(totalAmountDue) * -1) as TotalAmt 
			from ComDataReconcile cdr2 
			where Cdr2.CardNo = cdr.CardNo and cdr2.IsCredit = ''C'' 
			) as Temp) = 0
		)

		BEGIN
			if @CURRENTSTATUS <> @TRANSACTIONINBALANCE  -- Status has Changed
				begin
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @TRANSACTIONINBALANCE,
						APReviewed = 0,
						APResolved = 1
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return
		END




-------------------------------------------------------------------------------------------------------
-- check status
-- Settled But Out of Balance (Status Type 1)
-- Transaction Out of Balance (Status Type 22174)

if exists(Select top 1 ''X'' From CWI_JobMediaBuy s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Inner Join 
			ComDataReconcile cdr on
		scd.CCNumber = cdr.CardNo
		Where
			s.ID = @SETTLEMENTID
		and
			s.ActualCost <> (Select sum(TotalAmt) from 
					(Select sum(totalAmountdue) as Totalamt from ComDataReconcile cdr2  
					where cdr2.Cardno = cdr.Cardno and cdr2.IsCredit = ''D'' 
					Union Select (sum(totalAmountDue) * -1) as TotalAmt 
					from ComDataReconcile cdr2 
					where Cdr2.CardNo = cdr.CardNo and cdr2.IsCredit = ''C'' 
					) as Temp)
		)

		begin
			if @CURRENTSTATUS <> @TRANSACTIONOUTOFBALANCE  -- Status has Changed
				begin
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @TRANSACTIONOUTOFBALANCE,
						APReviewed = 0,
						APResolved = 0
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return

		end


-------------------------------------------------------------------------------------------------------
-- check status
-- OLD Settled But Out of Balance DNR or Cancelled (Status Type 1)
-- Transaction Out of Balance DNR or Cancelled (Status Type 22174)
if exists(Select top 1 ''x'' From CWI_JobMediaBuy s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Inner Join 
			ComDataReconcile cdr on
		scd.CCNumber = cdr.CardNo
		Where
			s.ID = @SETTLEMENTID
		and
			(s.IsCancelled = 1 or s.dnr = 1)
		and
					(Select sum(TotalAmt) from 
					(Select sum(totalAmountdue) as Totalamt from ComDataReconcile cdr2  
					where cdr2.Cardno = cdr.Cardno and cdr2.IsCredit = ''D'' 
					Union Select (sum(totalAmountDue) * -1) as TotalAmt 
					from ComDataReconcile cdr2 
					where Cdr2.CardNo = cdr.CardNo and cdr2.IsCredit = ''C'' 
					) as Temp) <> 0
		)

		begin
			if @CURRENTSTATUS <> @TRANSACTIONOUTOFBALANCE -- Status has Changed
				begin
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @TRANSACTIONOUTOFBALANCE,
						APReviewed = 0,
						APResolved = 0
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return

		end

------------------------------------------------------------------------------------------------
/*
--OLD No Settlement In Balance (Status Type = 9)
--No Settlement In Balance (Status Type = 9) PENDING
if exists (Select ''x'' From Settlements s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Where

			s.ID = @SETTLEMENTID
		and
			(s.dnr = 1 or s.Cancelled = 1)
		and
			scd.CCNumber not in (Select distinct CardNo from ComDataReconcile)
		)

		BEGIN
			if @CURRENTSTATUS <> 9  -- Status has Changed
				begin
					Update Settlements 
						Set APStatus = 9,
						APReviewed = 0,
						APResolved = 1
						 Where ID = @SETTLEMENTID
					
					return
				end
			else
				return
		END

*/



------------------------------------------------------------------------------------------------

-- CC Isssued - w/ Decline After Approval (Status Type = 4)
-- AUTHORIZATION DECLINED AFTER APPROVAL (Status Type = 22172)
if exists(Select top 1 ''x''
		from CWI_JobMediaBuy  s
		inner join SettlementComDataCCNumber scd
		on
			s.ID = scd.SettlementID
		inner join
			ComDataTransaction cdt on
		scd.CCNumber = cdt.CardNo
		where
			s.IsCancelled = 0
		and
			s.dnr = 0
		and
			(cdt.ApprovalNumber = 0 and cdt.TotalAmountBilled = 0)
		and
			convert(datetime,cdt.TransactionDate + '' '' + cdt.TransactionTime) > (Select  min(convert(datetime,TransactionDate + '' '' + TransactionTime))
												from CWI_JobMediaBuy s
												inner join SettlementComDataCCNumber scd
												on
													s.ID = scd.SettlementID
												inner join
													ComDataTransaction cdt2 on
												scd.CCNumber = cdt2.CardNo
												where
													s.IsCancelled = 0
												and
													s.dnr = 0
												and
													cdt2.ApprovalNumber <> 0
												and 
													cdt2.CardNo = cdt.Cardno
												)
		and
			s.ID = @SETTLEMENTID
		)

		BEGIN
			if @CURRENTSTATUS <> @AUTHORIZATIONDECLINEDAFTERAPPROVAL  -- Status has Changed
				begin
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @AUTHORIZATIONDECLINEDAFTERAPPROVAL,
						APReviewed = 0,
						APResolved = 0
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return
		END

--------------------------------------------------------------------------------------------------------

-- OLD Transactions Out of Balance Cancelled or DNR (Status = 3)
-- Authorization Out of Balance Cancelled or DNR (Status = 22173)
if exists(Select top 1 ''X'' From CWI_JobMediaBuy s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Inner Join 
			ComDataTransaction cdt ON scd.CCNumber = cdt.CardNo   
		Where PayMethodLookupId = 852 /* virtual card */   
			and s.ID = @SETTLEMENTID
			and (s.IsCancelled = 1 or s.dnr = 1)
			and (Select sum(TotalAmt) from 
					(Select sum(Preauthamt) as Totalamt from ComDataTransaction cdt2  
					where cdt2.Cardno = cdt.Cardno and cdt2.ApprovalNumber > 0 
					Union Select sum(totalAmountBilled) as TotalAmt 
					from ComDataTransaction cdt2 
					where Cdt2.CardNo = cdt.CardNo and cdt2.ApprovalNumber = 0 
					and cdt2.TotalAmountBilled <> 0) as Temp) <> 0
		and
			cdt.CardNo not in (Select distinct CardNo from ComDataReconcile)
		)

	begin
		if @CURRENTSTATUS <> @AUTHORIZATIONOUTOFBALANCE  -- Status has Changed
			begin
				Update CWI_VCMediaBuy 
					Set VCStatusLookupId = @AUTHORIZATIONOUTOFBALANCE,
					APReviewed = 0,
					APResolved = 0
					 Where MediaBuyId = @SETTLEMENTID
				
				return
			end
		else
			return
	end


if exists(Select top 1 ''X'' From CWI_JobMediaBuy s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Inner Join 
			ComDataTransaction cdt ON scd.CCNumber = cdt.CardNo   
		Where PayMethodLookupId = 852 /* virtual card */  
			and s.ID = @SETTLEMENTID
			and s.ActualCost <> 
				(Select sum(TotalAmt) from 
					(Select sum(Preauthamt) as Totalamt from ComDataTransaction cdt2  
					where cdt2.Cardno = cdt.Cardno and cdt2.ApprovalNumber > 0 
					Union Select sum(totalAmountBilled) as TotalAmt 
					from ComDataTransaction cdt2 
					where Cdt2.CardNo = cdt.CardNo and cdt2.ApprovalNumber = 0 
					and cdt2.TotalAmountBilled <> 0) as Temp)
		and
			cdt.CardNo not in (Select distinct CardNo from ComDataReconcile)
		)

	begin
		if @CURRENTSTATUS <> @AUTHORIZATIONOUTOFBALANCE  -- Status has Changed
			begin
				Update CWI_VCMediaBuy 
					Set VCStatusLookupId = @AUTHORIZATIONOUTOFBALANCE,
					APReviewed = 0,
					APResolved = 0
					 Where MediaBuyId = @SETTLEMENTID
				
				return
			end
		else
			return
	end


------------------------------------------------------------------------------------------------------------

-- OLD Transactions In Balance (Status Type = 6)
-- Authorization In Balance (Status Type = 22143)
if exists (Select top 1 ''x'' From CWI_JobMediaBuy s 
		Right Join 
			SettlementComDataCCNumber scd ON s.ID = scd.SettlementID 
		Inner Join 
			ComDataTransaction cdt ON scd.CCNumber = cdt.CardNo   
		Where PayMethodLookupId = 852 /* virtual card */ 
			and s.ID = @SETTLEMENTID
			and s.ActualCost = 
				(Select sum(TotalAmt) from 
					(Select sum(Preauthamt) as Totalamt from ComDataTransaction cdt2  
					where cdt2.Cardno = cdt.Cardno and cdt2.ApprovalNumber > 0 
					Union Select sum(totalAmountBilled) as TotalAmt 
					from ComDataTransaction cdt2 
					where Cdt2.CardNo = cdt.CardNo and cdt2.ApprovalNumber = 0 
					and cdt2.TotalAmountBilled <> 0) as Temp)
		and
			cdt.CardNo not in (Select distinct CardNo from ComDataReconcile)

		)

		BEGIN
			if @CURRENTSTATUS <> @AUTHORIZATIONINBALANCE  -- Status has Changed
				begin
--					PRINT ''ABOUT TO UPDATE SETTLEMENT FOR STATUS TYPE 6''
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @AUTHORIZATIONINBALANCE,
						APReviewed = 0,
						APResolved = 0
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return
		END


-----------------------------------------------------------------------------------------------------------------

-- OLD CC Isssued - w/ Decline only (Status Type 2)
-- AuthorizationS Declined (Status Type 22171)
if exists (Select top 1 ''X''
		from CWI_JobMediaBuy s
		inner join SettlementComDataCCNumber scd
		on
			s.ID = scd.SettlementID
		inner join
			ComDataTransaction cdt on
		scd.CCNumber = cdt.CardNo
		where
			(cdt.ApprovalNumber = 0  and cdt.TotalAmountBilled = 0)
		and
			s.IsCancelled = 0
		and
			s.dnr = 0
		and
			s.ID = @SETTLEMENTID
		)

	begin
		if @CURRENTSTATUS <> @AUTHORIZATIONSDECLINED  -- Status has Changed
			begin
				Update CWI_VCMediaBuy 
					Set VCStatusLookupId = @AUTHORIZATIONSDECLINED,
					APReviewed = 0,
					APResolved = 0
					 Where MediaBuyId = @SETTLEMENTID
				
				return
			end
		else
			return
	end


----------------------------------------------------------------------------------------------------------

-- OLD CC Issued, CC Updated (Status = 7)
-- CC Limit Updated (Status = 22142)
if exists(Select top 1 ''X''
		from CWI_JobMediaBuy s
		inner join SettlementComDataCCNumber scd
		on
			s.ID = scd.SettlementID
		where
			ccNumber not in (Select CardNo from ComDataTransaction)
		and
			s.id in (Select SettlementID from ComDataCommunicationControl Where ComDataTemplateID <> 1)
		and
			s.ID = @SETTLEMENTID
		)
		BEGIN
			if @CURRENTSTATUS <> @CREDITCARDLIMITUPDATED  -- Status has Changed
				begin
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @CREDITCARDLIMITUPDATED,
						APReviewed = 0,
						APResolved = 0
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return
		END

----------------------------------------------------------------------------------------------------------------

-- CC Issued, CC Limit not updated (Status Type = 8)
-- CC Requested (Status Type = 22141)
if exists(Select top 1 ''x''
		from CWI_JobMediaBuy s
		inner join SettlementComDataCCNumber scd
		on
			s.ID = scd.SettlementID
		where
			ccNumber not in (Select CardNo from ComDataTransaction)
		and
			s.id not in (Select SettlementID from ComDataCommunicationControl Where ComDataTemplateID <> 1)
		and
			s.ID = @SETTLEMENTID

		)

		BEGIN
			if @CURRENTSTATUS <> @CREDITCARDREQUESTED  -- Status has Changed
				begin
					Update CWI_VCMediaBuy 
						Set VCStatusLookupId = @CREDITCARDREQUESTED,
						APReviewed = 0,
						APResolved = 0
						 Where MediaBuyId = @SETTLEMENTID
					
					return
				end
			else
				return

		END

--------------------------------------------------------------------------------------------------------------------

--Status Not found

Update CWI_VCMediaBuy
	Set VCStatusLookupId = 0,
	APReviewed = 0,
	APResolved = 0
Where
	MediaBuyId = @SETTLEMENTid
















' 
END
GO


