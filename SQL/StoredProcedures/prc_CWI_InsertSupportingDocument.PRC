IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_InsertSupportingDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_InsertSupportingDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_InsertSupportingDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- prc_CWI_InsertSupportingDocument ''VendorDocTest,VendorDocTest1,VendorDocTest2'', 203

CREATE PROC [dbo].[prc_CWI_InsertSupportingDocument]
	 @Items varchar(MAX), -- Documents ''Service Documents, ClientDocument, VendorDocument''
	 @AssignTo int -- Assigned to which object Service(201), client (202) OR Vendor (203)
AS

DECLARE @ItemsLookupTypeId int
DECLARE @StartingLookupId int

SET @ItemsLookupTypeId = 1
SET @StartingLookupId = NULL

select @StartingLookupId = max(Id) from Lookup 
where LookupTypeId = @ItemsLookupTypeId

IF @StartingLookupId IS NULL
begin 
	SELECT @StartingLookupId = RangeStarting from LookupType
	WHERE Id = @ItemsLookupTypeId
end
else
begin
	SELECT @StartingLookupId = @StartingLookupId +1
end

DECLARE @tbl TABLE(Item varchar(max))
--comma seperated groups are inserted into the temp table
INSERT INTO @tbl
select * FROM dbo.fnc_utl_Split(@Items,'','')

--select * from @tbl

DECLARE @tblLookup TABLE
(
	[Id] [int] NOT NULL IDENTITY(1,1),
	[LookupId] int,
	[LookupTypeId] [int] NOT NULL,
	[LookupName] [varchar](100) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	IsExisting bit default 0
)



INSERT INTO @tblLookup
(
	[LookupId],
	[LookupTypeId]
    ,[LookupName]
    ,[SortOrder]
    ,[IsActive]
    , IsExisting
)

SELECT * FROM
(
SELECT
	L.ID,s.*, CASE WHEN L.Id IS NULL THEN 0 ELSE 1 END IsExisting
FROM
	(
	select  @ItemsLookupTypeId lookupid,ltrim(rtrim(Item)) item,0 sort,1 isactive from @tbl t
	WHERE ltrim(rtrim(Item)) <> ''''
	) s
	LEFT OUTER JOIN
		Lookup L
		ON s.item = l.LookupName AND  L.LookupTypeId = 1
		) x
ORDER BY x.IsExisting



UPDATE  @tblLookup SET [LookupId] = ID + @StartingLookupId -1
WHERE IsExisting = 0

--select * from @tblLookup


INSERT INTO [dbo].[Lookup]
           ([Id]
           ,[LookupTypeId]
           ,[LookupName]
           ,[SortOrder]
           ,[IsActive]
           )
		   
select 
		lookupId
        ,tl.LookupTypeId
        ,tl.LookupName
        ,tl.[SortOrder]
        ,tl.[IsActive]
           
from @tblLookup tl
WHERE IsExisting = 0



select * from Lookup 
where LookupTypeId = @ItemsLookupTypeId
order by LookupTypeId desc


INSERT INTO CWI_DocCategory
(
ObjectLookupId, DocTypeLookupID, ModifiedOn, ModifiedBy
)


SELECT @AssignTo,TL.LookupId, GETDATE(), SUSER_NAME()  FROM @tblLookup TL
LEFT OUTER JOIN CWI_DocCategory DC
	ON DC.DocTypeLookupID = TL.LookupId
	AND DC.ObjectLookupId = @AssignTo
WHERE
 	DC.Id IS NULL







' 
END
GO
