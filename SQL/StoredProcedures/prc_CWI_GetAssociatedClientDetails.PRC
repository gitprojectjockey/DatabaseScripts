/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAssociatedClientDetails]    Script Date: 9/12/2014 1:51:09 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAssociatedClientDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetAssociatedClientDetails]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetAssociatedClientDetails]    Script Date: 9/12/2014 1:51:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetAssociatedClientDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: [prc_CWI_GetAssociatedClientDetails]
* Purpose : This PROC would be called TO retrieve the client corporate relation
* Invoked from : Client.aspx
* CREATED: Vijesh Mahi
* CREATED ON : 4 Sep 2014
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

********************************************************************** 
exec dbo.prc_CWI_GetAssociatedClientDetails 15674,14903

**********************************************************************/ 
CREATE PROCEDURE [dbo].[prc_CWI_GetAssociatedClientDetails] 
@inCorporateId int,
@inClientId int
AS
BEGIN
	
	SET NOCOUNT ON;	
	Declare @inAssociationId int=NULL,@vcCorporateName varchar(500)

	select @inAssociationId = Id from [dbo].[CWI_ClientAssociation] 
		where CoporateId=@inCorporateId and ClientId=@inClientId 
			and IsRemoved=0
	
	if @inAssociationId IS NULL
	begin

		select @vcCorporateName=ClientCode+'' - ''+ClientName from CWI_Client where ID=@inCorporateId

		select 
		@vcCorporateName as CorporateName,
		@inCorporateId as CorporateId,
		C.ClientCode+'' - ''+C.ClientName as ClientName,
		C.ID as ClientId,
		A.City,
		S.StateName,
		NULL as EffectiveDate
		from [dbo].[CWI_Client] C 
		inner join [dbo].[CWI_Address] A on C.AddressID=A.ID
		inner join [dbo].[State] S on A.StateID=S.ID		
		where C.Id=@inClientId

	end
	else
	begin

		select CC.ClientCode+'' - ''+CC.ClientName as CorporateName,
		CC.ID as CorporateId,
		C.ClientCode+'' - ''+C.ClientName as ClientName,
		C.ID as ClientId,
		A.City,
		S.StateName,
		CA.EffectiveDate
		from [dbo].[CWI_ClientAssociation] CA
		inner join [dbo].[CWI_Client] C on CA.ClientId=C.ID
		inner join [dbo].[CWI_Address] A on C.AddressID=A.ID
		inner join [dbo].[CWI_Client] CC on CA.CoporateId=CC.ID
		inner join [dbo].[State] S on A.StateID=S.ID
		where CA.Id=@inAssociationId

	end

	SET NOCOUNT OFF;

END	






	





' 
END
GO
