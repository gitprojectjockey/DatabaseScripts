/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVCPaymentMethod]    Script Date: 8/1/2014 9:12:23 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVCPaymentMethod]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVCPaymentMethod]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVCPaymentMethod]    Script Date: 8/1/2014 9:12:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVCPaymentMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************************  
* PROCEDURE: [prc_CWI_SetVCPaymentMethod]  
* Purpose : This PROC would be called to virtaul carddetails
* Invoked from : ManageVirtualCard.aspx
* CREATED: Saravanan 12JUN14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec [prc_CWI_SetVCPaymentMethod] @inVCId  = 4,@PaymentMethod=852,@Comment=''fgfhfhjfjh ghgh'', @Author=8
**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_SetVCPaymentMethod] 
	@inVCId bigint ,
	@PaymentMethod INT,
	@Comment Varchar(max),
	@Author int
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @dt datetime = getdate()
		declare @message NVARCHAR(2000) 
		DECLARE @delimiter CHAR(1) = CHAR(225);
		DECLARE @InsertAction varchar(8000)
		DECLARE @InsertActionLink varchar(8000)
		DECLARE @AuthorName varchar(1000)
		DECLARE @dtString varchar(100) =  FORMAT( @dt, ''MM/dd/yyyy hh:mm tt'');
		DECLARE @tblPay TABLE
		(
				comment varchar(max)
		)

		DECLARE @mediabuyId bigint=0,@Jobid bigint=0,@InvoiceId Bigint=0

		SET	@mediabuyId=(SELECT MediaBuyId FROM CWI_VCMediaBuy WHERE Id = @inVCId);
		SELECT @Jobid=JobId FROM CWI_JobMediaBuy WHERE id=@mediabuyId;
		SELECT @InvoiceId=ISNULL(InvoiceId,0) from CWI_Job WHERE id=@Jobid;

IF(ISNULL(@InvoiceId,0)=0 )
BEGIN
	UPDATE CWI_JobMediaBuy 
		SET
			 PayMethodLookupId = @PaymentMethod 
			 OUTPUT
			 
			 CASE WHEN (INSERTEd.PayMethodLookupId<>DELETED.PayMethodLookupId OR 				
INSERTEd.PayMethodLookupId=DELETED.PayMethodLookupId )THEN ''Payment Method changed from ''
			 +Convert(varchar,CASE WHEN DELETED.PayMethodLookupId=851 then 
			 '' Invoice '' else +Convert(varchar,CASE WHEN DELETED.PayMethodLookupId=852 then 
			 '' Virtual Card '' else Convert(varchar,CASE WHEN DELETED.PayMethodLookupId=854 then 
			 ''Ghost Card '' else '' '' END) +Convert(varchar,CASE WHEN inserted.PayMethodLookupId=851 then
			  ''to Invoice'' else '''' END) END) +Convert(varchar,CASE WHEN inserted.PayMethodLookupId=854 then 
			  ''to Ghost Card'' else '''' END) END) +Convert(varchar,CASE WHEN inserted.PayMethodLookupId=852 then 
			  ''to Virtual Card'' else '''' END)+@delimiter ELSE '''' end 
			 
			 INTO @tblPay
			 
		WHERE Id = @mediabuyId

		DECLARE @updHistory varchar(max),@ActionVal varchar(max);
				SELECT @updHistory = comment from @tblPay

				Select @updHistory=Items FROM dbo.fnc_SplitCommaSeparatedValuesIntoTable(@updHistory,@delimiter) 
WHERE LTRIM(RTRIM(items)) <> '''';		
		--select * from @tblPay;

		--Inserting into Action table to track History
		SELECT @AuthorName = Names FROM CWI_User WHERE Id = @author

		EXEC prc_CWI_SetComment @author,  217/*Virtual Card Change Pay Method*/, @mediabuyId, NULL, @Comment, 1

       IF(@updHistory='''' )
BEGIN

 SET @updHistory=''Payment method Updated'';

END


		SET @InsertAction = @updHistory + '' by ''  + @AuthorName + '' on '' + @dtString
		
		EXEC prc_CWI_SetAction @ObjectLookupId = 211/*Virtual Card*/, 
			@ObjectId = @mediabuyId,
			@ActionLookupId = 10025/*Payment method updated*/,
			@Action = @InsertAction,
			@ActionWithLink = @InsertAction,
			@CreatedBy = @author;
		UPDATE COMDATACommunicationControl SET CCLimit=0.01, ComDataTemplateID=2 WHERE SettlementID= @mediabuyId;
 
END
ELSE		
	BEGIN
	SET @message = ''Can not change the Payment method. Please refresh the page'';
		THROW 50000,@message , 1; 
	END
	
	END TRY
	BEGIN CATCH	  
	IF @@TRANCOUNT >0 
		ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError;
		THROW;
	END CATCH
IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;

	RETURN

END





' 
END
GO
