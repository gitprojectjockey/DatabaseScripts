/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceDelivery]    Script Date: 11/7/2014 3:49:30 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceDelivery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetCorrespondenceDelivery]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetCorrespondenceDelivery]    Script Date: 11/7/2014 3:49:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetCorrespondenceDelivery]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_SetCorrespondenceDelivery 
* Purpose : This PROC would be called TO create delivery methods before creating correspondence
* Invoked from : CorrespondenceService
* CREATED: MohanKumar Sundaram	24APR14
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
  25JUl14	Mohankumar		From email address and name inserted in correspondence delivery          
  07NOV14	Mohankumar		Delivery methods set up base don the setting in CWI_CorrespondenceDeliveryMethod table   
**********************************************************************  
Execution example :
**********************************************************************  
exec prc_CWI_SetCorrespondenceDelivery 1, 3,''\\fileserver\folder\'',''1.pdf''
  
**********************************************************************/ 
CREATE PROC [dbo].[prc_CWI_SetCorrespondenceDelivery]
	@CorrespondenceId bigint,
	@author int,
	@FilePath varchar(max),
	@File varchar(max)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @fax varchar(100),
		@VendorId int ,
		@CorrespondenceLookupId int  ,
		@DivisionId int,
		@authorName varchar(100) = '''',
		@authorEmail varchar(100) = ''''

	SELECT @authorName = Names, @authorEmail = Email  FROM CWI_User WHERE Id = @author

	/* CHeck if correspondence delivery generated for the correspondence */
	
	IF EXISTS(SELECT TOP 1 1 FROM CWI_CorrespondenceDelivery WHERE CorrespondenceId = @CorrespondenceId AND IsTrashed = 0)
	BEGIN
		UPDATE CWI_CorrespondenceDelivery 
		SET [FilePath] =  @FilePath , [File] = @File
		WHERE  CorrespondenceId = @CorrespondenceId AND IsTrashed = 0

		RETURN
	END

	SELECT 
		@VendorId = VendorId,
		@CorrespondenceLookupId = CorrespondenceTypeLookupId  ,
		@DivisionId = ClientId
	FROM
		CWI_Correspondence
	WHERE
		Id = @CorrespondenceId

	DECLARE  @tblVendorCorres TABLE
	(
		DeliverMethodId int,
		Fax varchar(200),
		Email varchar(max),
		FTPServer varchar(200),
		FTPPort varchar(200),
		FTPUser varchar(200),
		FTPPassword varchar(200)
	)
	
	INSERT INTO @tblVendorCorres
	select 
		VC.DeliveryMethodLookupId,
		VC.Fax,
		ISNULL(VCon.Email, VCD.EmailID) Email,
		ftp.Server,
		ftp.Port,
		ftp.UserName,
		ftp.Password
	from 
		CWI_VendorCorrespondence VC
		INNER JOIN CWI_CorrespondenceDeliveryMethod CDM
			ON CDM.CorrespondenceLookupId =  VC.CorrespondenceLookupId
				AND CDM.DeliveryMethodLookupId = VC.DeliveryMethodLookupId
				AND CDM.IsActive = 1
		LEFT OUTER JOIN CWI_VendorCorrespondenceDelivery VCD
			ON VC.Id = VCD.VendorCorrespondenceID 
		LEFT OUTER JOIN CWI_VendorContact VCon
			ON VCon.Id = VCD.VendorContactID
		LEFT OUTER JOIN CWI_VendorCorrespondenceFTP ftp
			ON VC.Id = ftp.VendorCorrespondenceID
	WHERE
		VC.VendorId = @VendorId
		AND VC.CorrespondenceLookupId = @CorrespondenceLookupId
		and ISNULL(VC.IsActive,1) = 1
			and ISNULL(VCD.IsActive,1) = 1 
		and ISNULL(Vcon.IsDeleted,0) = 0
		and 
		(
			(VCD.IsAssociatedClients = 0)
			OR
			VCD.VendorContactID in 
				(select VendorContactId from CWI_VendorContactClient where ClientId = @DivisionId)
			)
	 
	UPDATE @tblVendorCorres SET Email = t.Email
	FROM
		@tblVendorCorres tbl
		INNER JOIN
		(
			SELECT p1.DeliverMethodId,Stuff(
						( SELECT Email + '','' 
							FROM @tblVendorCorres p2
							WHERE p2.DeliverMethodId = p1.DeliverMethodId
							ORDER BY Email
							FOR XML  PATH(''''),type ).value(''.'', ''nvarchar(max)'') 
							, 1, 0, '''') AS Email
						FROM @tblVendorCorres p1
						GROUP BY  DeliverMethodId 
						) t
					ON  t.DeliverMethodId = tbl.DeliverMethodId

	

	IF NOT EXISTS (SELECT top 1 1 FROM @tblVendorCorres)
	BEGIN
		
		SELECT top 1 @fax = Fax FROM
		(
		SELECT distinct dbo.fnc_FormatRemovalPhone(Fax,default) as Fax, 1 priority FROM CWI_VendorContact VC
		WHERE VendorId = @VendorId
		AND LTRIM(RTRIM(ISNULL(Fax,''''))) <> '''' AND IsDeleted = 0
		UNION 
		SELECT dbo.fnc_FormatRemovalPhone(WorkFax,default) as WorkFax, 2 priority FROM CWI_Vendor V INNER JOIN  CWI_Address BA ON V.AddressId_Billing = BA.ID
		WHERE V.Id = @VendorId
		AND LTRIM(RTRIM(ISNULL(WorkFax,''''))) <> ''''
		UNION 
		SELECT dbo.fnc_FormatRemovalPhone(WorkFax,default) as WorkFax, 3 priority FROM CWI_Vendor V INNER JOIN  CWI_Address PA ON V.AddressId_Physical = PA.ID
		WHERE V.Id = @VendorId
		AND LTRIM(RTRIM(ISNULL(WorkFax,''''))) <> '''' 
		UNION
		SELECT VC.Fax, 4 priority FROM CWI_VendorCorrespondence VC
			Inner Join
			CWI_Vendor V ON V.id=vc.VendorId and VendorId=@VendorId and VC.Fax is not null  AND LTRIM(RTRIM(ISNULL(Fax,''''))) <> ''''
				AND VC.DeliveryMethodLookupId= 804 /*fax*/
				and VC.CorrespondenceLookupId =@CorrespondenceLookupId 
		) x

		Order by x.priority

		INSERT INTO @tblVendorCorres
		(DeliverMethodId ,
		Fax )
		VALUES
		(
		804,
		@Fax)
	END
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE CWI_CorrespondenceDelivery SET IsTrashed = 1
		WHERE CorrespondenceId = @CorrespondenceId
						
		INSERT CWI_CorrespondenceDelivery
		(
			CorrespondenceId, 
			DeliveryMethodLookupId, 
			DeliveryStatusLookupId, 
			Fax, 
			Email, 
			FTPServer, FTPPort, FTPUser, FTPPassword,
			CreatedBy,
			LastModifiedBy,
			FilePath,
			[File],
			[EmailTemplateId],
			FromEmailAddress,
			FromEmailUserName
		)

		select distinct 
			@CorrespondenceId ,
			DeliverMethodId ,
			3152,/*Pending*/
			Fax ,
			Email ,
			FTPServer ,
			FTPPort ,
			FTPUser,
			FTPPassword ,
			@author,
			@author,
			@FilePath,
			@File,
			T.EmailTemplateId,
			@authorEmail,
			@authorName
		from @tblVendorCorres D
		LEFT OUTER JOIN
			(
				select DE.*, ET.TemplateFile, ET.TemplateSubject 
				from CWI_CorrespodenceDeliveryEmailTemplate  DE
				INNER JOIN CWI_EmailTemplate ET
					ON DE.EmailTemplateId = ET.Id
				WHERE
					CorrespodenceLookupId = @CorrespondenceLookupId
					AND DE.IsActive = 1 AND ET.IsActive = 1
			) T
			ON 
				D.DeliverMethodId = T.DeliveryMethodLookupId

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT >0 
			ROLLBACK TRANSACTION ;
		EXEC prc_CWI_AppRaiseError; 
		THROW
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION Trans1;




	SET NOCOUNT OFF
END








' 
END
GO


