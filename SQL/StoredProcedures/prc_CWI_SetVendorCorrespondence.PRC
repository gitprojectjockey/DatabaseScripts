/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorCorrespondence]    Script Date: 11/7/2014 7:56:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorCorrespondence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetVendorCorrespondence]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetVendorCorrespondence]    Script Date: 11/7/2014 7:56:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetVendorCorrespondence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetVendorCorrespondence
* Purpose : This PROC would be called TO insert/update vendor correspondence
* Invoked from : Vendor.aspx
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetVendorCorrespondence @Correspondence = ''<DocumentElement>
  <VendorCorrespondence>
    <Id>-1</Id>
    <CorrespondenceLookupId>702</CorrespondenceLookupId>
    <DeliveryMethodLookupId>801</DeliveryMethodLookupId>
    <IsActive>true</IsActive>
    <Fax />
    <VendorContactID>14129</VendorContactID>
    <EmailID>alabrecsque@nextmediagroup.com</EmailID>
    <IsAssociatedClients>false</IsAssociatedClients>
    <DeliveryMethod />
    <Name />
    <NameType />
	
  </VendorCorrespondence>
  <VendorCorrespondence>
    <Id>-2</Id>
    <CorrespondenceLookupId>702</CorrespondenceLookupId>
    <DeliveryMethodLookupId>803</DeliveryMethodLookupId>
    <IsActive>true</IsActive>
    <Fax />
    <VendorContactID>14129</VendorContactID>
    <EmailID>sdasdsa@tessdsfds.com</EmailID>
    <IsAssociatedClients>false</IsAssociatedClients>
    <DeliveryMethod />
    <Name />
    <NameType />
  </VendorCorrespondence>
  <VendorCorrespondence>
    <Id>-3</Id>
    <CorrespondenceLookupId>702</CorrespondenceLookupId>
    <DeliveryMethodLookupId>801</DeliveryMethodLookupId>
    <IsActive>true</IsActive>
    <Fax />
    <VendorContactID>14129</VendorContactID>
    <EmailID>Test@trippak.com</EmailID>
    <IsAssociatedClients>true</IsAssociatedClients>
    <DeliveryMethod />
    <Name />
    <NameType />
  </VendorCorrespondence>
</DocumentElement>'', 

@VendorId=1072, @Author=8
  
  ************************************************************************
  Useful query for debugging for data sync:
  select e.* from AwPubsEmailCorrespondenceEmailSchedule  e
	inner join awpubsCorrespondenceprotocol cp
			on cp.id = e.pubsemailcorrescode 
		inner join papers p
			on p.id = cp.pubid
			where p.papercode = ''ajayt''
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetVendorCorrespondence]
    @Correspondence XML,
	
	@VendorId int,
	@Author	int	
AS

DECLARE @tbl TABLE
(
	CorrespondenceLookupId1 int,
	DeliveryMethodLookupId1 int,
	Fax1 varchar(300) ,	
	VendorContactID1 INT
	,EmailID1 VARCHAR(400)
	,IsAssociatedClients1 bit,
	IsActive1 bit,
	Status1 bit 
)


DECLARE @tblDeliveryTemp TABLE
(
	VendorCorrespondenceID1 INT	
	,VendorContactID1 INT
	,EmailID1 VARCHAR(400)
	,IsAssociatedClients1 bit,
	Status1 bit
)
Declare @tblCorrespondence TABLE
(
Id int,
DeliveryMethodLookupId int,
CorrespondenceLookupId int,
EmailID varchar(100),
IsAssociatedClients bit,
VendorContactID int,
[Status] bit 
)
declare @CorrespondenceLookupIdRef INT;
	BEGIN TRANSACTION Trans1

	BEGIN TRY
		--Read the data from XML and store in the table variable
		INSERT INTO @tbl
		(
			CorrespondenceLookupId1,
			DeliveryMethodLookupId1,
			Fax1,
			VendorContactID1,
			EmailID1,
			IsActive1,
			IsAssociatedClients1,
			Status1
		)


		select 
			COLX.value(''(./CorrespondenceLookupId)[1]'',''int''),
			COLX.value(''(./DeliveryMethodLookupId)[1]'',''int''),
			COLX.value(''(./Fax)[1]'',''varchar(max)''),
			COLX.value(''(./VendorContactID)[1]'',''int''),
			COLX.value(''(./EmailID)[1]'',''varchar(max)''),
			COLX.value(''(./IsActive)[1]'',''bit''),
			COLX.value(''(./IsAssociatedClients)[1]'',''bit''),
			COLX.value(''(./Status)[1]'',''bit'')
		from @correspondence.nodes(''DocumentElement/VendorCorrespondence'') AS TABX(COLX)


		--Insert the vendor correspondence for the non-existing
		INSERT INTO CWI_VendorCorrespondence
		(
		VendorId, CorrespondenceLookupId, DeliveryMethodLookupId, Fax, IsActive, CreatedBy,  ModifiedBy
		)
		SELECT
			distinct @VendorId,
			CorrespondenceLookupId1, DeliveryMethodLookupId1, '''', 0 , @Author, @Author
		FROM
			@tbl t
			LEFT OUTER JOIN CWI_VendorCorrespondence VC
			ON VC.VendorId = @VendorId AND t.CorrespondenceLookupId1 = VC.CorrespondenceLookupId
				AND VC.DeliveryMethodLookupId = t.DeliveryMethodLookupId1
		WHERE VC.Id IS NULL;

		--Update the vendor correspondence for the existing 
		UPDATE CWI_VendorCorrespondence
		SET
			
			Fax=Fax1,
			IsActive = COALESCE(IsActive1, (1)),
			ModifiedBy = @Author,
			ModifiedOn = getdate()
		FROM 
		 @tbl t
		 WHERE 
			VendorId = @VendorId AND
			CorrespondenceLookupId = CorrespondenceLookupId1 AND
			DeliveryMethodLookupId = DeliveryMethodLookupId1
		 			
		

		/*--- For Vendor Delivery */
		INSERT INTO @tblCorrespondence(Id,DeliveryMethodLookupId,CorrespondenceLookupId,EmailID,IsAssociatedClients,VendorContactID,[Status])
		SELECT VC.Id,vc.DeliveryMethodLookupId,VC.CorrespondenceLookupId,t.EmailID1,IsAssociatedClients1,VendorContactID1,Status1 from 
		@tbl t
		INNER JOIN CWI_VendorCorrespondence VC
		ON VC.VendorId = @VendorId AND t.CorrespondenceLookupId1 = VC.CorrespondenceLookupId
			AND VC.DeliveryMethodLookupId = t.DeliveryMethodLookupId1
			AND t.DeliveryMethodLookupId1 <> 804
			
			--SELECT * from @tblCorrespondence;
		

			INSERT INTO @tblDeliveryTemp(VendorCorrespondenceID1,VendorContactID1,EmailID1,IsAssociatedClients1,Status1)
			SELECT C.Id,C.VendorContactID,C.EmailID,C.IsAssociatedClients,C.[Status] from @tblCorrespondence C inner JOIN
			CWI_VendorCorrespondence D ON c.id=d.Id  ;
			--Select * from @tblDeliveryTemp;


			/*---- Update Vendor Delivery Contact--- */
	UPDATE [dbo].[CWI_VendorCorrespondenceDelivery] 
   SET --[VendorCorrespondenceID] = @CorrespondenceLookupIdRef
      --,[VendorContactClientID] = VendorContactClientID1
      --,[VendorContactID] = VendorContactID1
       [EmailID] = VC.EmailID
      ,[IsAssociatedClients] = VC.IsAssociatedClients  
	  ,[IsActive]=VC.[Status]   
      ,[ModifiedBy] = @Author
      ,[ModifiedOn] = GETDATE()
	  FROM @tblCorrespondence VC
	WHERE 
	 [CWI_VendorCorrespondenceDelivery].[VendorCorrespondenceID]=VC.ID AND [CWI_VendorCorrespondenceDelivery].[VendorContactID] = VC.VendorContactID AND [CWI_VendorCorrespondenceDelivery].EmailID=VC.EmailID;
	
			/*---- Insert Vendor Delivery Contact--- */
		INSERT INTO CWI_VendorCorrespondenceDelivery 
		(
		[VendorCorrespondenceID],[VendorContactID],[EmailID],[IsAssociatedClients],[IsActive],[CreatedBy],[CreatedOn],[ModifiedBy],[ModifiedOn]
		)
		 SELECT VendorCorrespondenceID1,VendorContactID1,EmailID1,IsAssociatedClients1,Status1,@Author,GETDATE(),@Author,GETDATE() from @tblDeliveryTemp DT
		left outer  Join CWI_VendorCorrespondenceDelivery VDC ON  dt.VendorContactID1 = VDC.VendorContactID 
		and VDC.VendorCorrespondenceID=DT.VendorCorrespondenceID1 where VDC.id is  null		;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION Trans1;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;




' 
END
GO


