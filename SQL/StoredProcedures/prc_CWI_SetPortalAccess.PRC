/****** Object:  StoredProcedure [dbo].[prc_CWI_SetPortalAccess]    Script Date: 9/10/2014 8:29:49 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetPortalAccess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetPortalAccess]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_SetPortalAccess]    Script Date: 9/10/2014 8:29:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetPortalAccess]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*******************************************************************  
* PROCEDURE: prc_CWI_SetPortalAccess     
* Purpose : This PROC would be called TO set portal access for client contacts 
* Invoked from : ClientPortalAccess.aspx	10SEP14
* CREATED: MohanKumar Sundaram 
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
**********************************************************************  
declare @p1 xml
set @p1=convert(xml,N''<DocumentElement><Access><Id>265</Id><HasAccess>true</HasAccess></Access><Access><Id>266</Id><HasAccess>false</HasAccess></Access><Access><Id>1484</Id><HasAccess>false</HasAccess></Access><Access><Id>2513</Id><HasAccess>true</HasAccess></Access></DocumentElement>'')
exec dbo.prc_CWI_SetPortalAccess @xmlAccess=@p1,@inCreatedBy=3
  
**********************************************************************/ 


CREATE PROCEDURE [dbo].[prc_CWI_SetPortalAccess]   
	@xmlAccess xml,
	@inCreatedBy int
	

AS
BEGIN


	BEGIN TRY
		DECLARE @tblAccess TABLE
		(
			CCId int,
			HasAccess bit
		)	
	
		Insert into @tblAccess
		select 
			COLX.value(''(./Id)[1]'',''int''),
			COLX.value(''(./HasAccess)[1]'',''bit'')
			
		from 
		@xmlAccess.nodes(''DocumentElement/Access'') AS TABX(COLX)
			


		UPDATE CWI_ClientContact
			Set IsCWPortalUser = HasAccess,
				ModifiedBy = @inCreatedBy,
				ModifiedOn = getdate()
		FROM CWI_ClientContact CC
			INNER JOIN @tblAccess t
				ON Id= CCId
				AND CC.IsCWPortalUser <> t.HasAccess
	END TRY		
	BEGIN CATCH	
	
		EXEC prc_CWI_AppRaiseError;
		THROW;   		
	END CATCH
END' 
END
GO


