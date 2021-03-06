IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientLookupByUserId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetClientLookupByUserId]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetClientLookupByUserId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetClientLookupByUserId 
* Purpose : This PROC would be called to return the client\division in hierarchy
* Invoked from : MarketingPlan.aspx.cs
* CREATED: MohanKumar 14JUN13
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  

**********************************************************************  
Execution example :
**********************************************************************  
 prc_CWI_GetClientLookupByUserId 0 , ''A''

**********************************************************************/ 

CREATE PROC [dbo].[prc_CWI_GetClientLookupByUserId]
	@UserId int = 0,
	@Hierarchy char(1) = ''A'' -- A- All, D-Division and C-Cient
AS
BEGIN
	DECLARE @tbl TABLE
	(
		ClientId int, 
		ClientCode varchar(10), 
		ClientName varchar(255), 
		ParentID int,
		ClientDesc varchar(500)
	)

	IF @UserId <>0
	begin
		INSERT INTO @tbl
		select F.*, Cast(ClientId as varchar(10)) + '' - '' + F.ClientCode + '' - '' + F.ClientName ClientDesc  
		from dbo.fnc_GetClientsForUser(@UserId, @Hierarchy) F
		INNER JOIN CWI_Client C
			ON C.id = F.ClientId AND  C.ClientStatusLookupID in (502,503) --Active and on hold  divisions 
			
		
	end
	else
	begin
		;WITH ClientCTE(ClientId, ClientCode, ClientName, ParentID)
		AS
		( 
			select  C.Id  ClientId, ClientCode, ClientName, ParentID from CWI_Client C
			WHERE ParentId is not null AND C.ClientStatusLookupID in (502,503) --Active and on hold  clients
		
			UNION ALL
			 SELECT   P.Id, P.ClientCode, P.ClientName, P.ParentID
			 FROM CWI_Client AS P
			  JOIN ClientCTE AS M
			   ON P.ID = M.ParentID
			   AND P.ClientStatusLookupID in (502,503) --Active and on hold  divisions 
		)
		INSERT INTO @tbl
		select  distinct *,Cast(ClientId as varchar(10)) + '' - '' + ClientCode + '' - '' + ClientName ClientDesc  from ClientCTE
		
		--order by ClientName
	end
	
		
	DELETE  FROM @tbl
	WHERE ClientId in
		(SELECT T.ClientId FROM @tbl T
		LEFT OUTER JOIN @tbl  P
		ON P.ClientId = t.ParentID 
		
	WHERE P.ClientId is null and t.ParentID is not null
	)

	DELETE  FROM @tbl
	WHERE ClientId in
		(
	SELECT P.ClientId FROM @tbl P
		LEFT OUTER JOIN @tbl  C
		ON P.ClientId = C.ParentID 
		WHERE P.ParentID IS NULL AND C.ClientId IS NULL
	) 

	SELECT * FROM @tbl
	order by ClientName
END


' 
END
GO


