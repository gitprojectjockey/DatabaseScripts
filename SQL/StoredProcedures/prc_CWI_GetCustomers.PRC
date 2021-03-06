/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCustomers]    Script Date: 9/18/2013 7:50:14 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCustomers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_GetCustomers]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_GetCustomers]    Script Date: 9/18/2013 7:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_GetCustomers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*******************************************************************  
* PROCEDURE: prc_CWI_GetCustomers 
* Purpose : This PROC would be called to Get the customer(client) details 
* Invoked from :AssignCustomerToContact.aspx
* CREATED: Saravanan Mahalingam
* MODIFICATION HISTORY  
* DATE      AUTHOR          DESCRIPTION  
            

**********************************************************************  
Execution example :
********************************************************************** 

exec [prc_CWI_GetCustomers] @ClientID="13957,14174"
 **********************************************************************/
CREATE PROCEDURE [dbo].[prc_CWI_GetCustomers] 
	@ClientID varchar(Max)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.ID as ClientID,CONVERT(Varchar, C.ID) +'' - ''+C.ClientCode + '' - '' + C.ClientName as ''ClientName''from CWI_Client C
	INNER JOIN

				dbo.Lookup L1
			ON 
				C.ClientStatusLookupID = L1.ID
			INNER JOIN 
				dbo.Lookup L2
			ON 
				C.HierarchyTypeLookupID = L2.ID	 where ParentID is NULL AND C.ID not in (Select Items from fnc_SplitCommaSeparatedValuesIntoTable(@ClientID,'','') ) AND L1.LookupName IN(''Active'',''OnHold'',''Prospect'');
END
' 
END
GO
