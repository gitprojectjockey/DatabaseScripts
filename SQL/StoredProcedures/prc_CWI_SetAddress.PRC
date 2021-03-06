/****** Object:  StoredProcedure [dbo].[prc_CWI_SetAddress]    Script Date: 7/2/2013 5:25:33 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAddress]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_CWI_SetAddress]
GO
/****** Object:  StoredProcedure [dbo].[prc_CWI_SetAddress]    Script Date: 7/2/2013 5:25:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_CWI_SetAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[prc_CWI_SetAddress]
	@AddressId int  = 0 out,
	@AddressLine1 varchar(255),
	@AddressLine2 varchar(255),
	@CountryID int,
	@StateID int,
	@City varchar(50),
	@Zip varchar(50),
	@WorkPhone varchar(50),
	@WorkExtn varchar(10),
	@WorkFax varchar(50),
	@Author int
AS
BEGIN
	IF @AddressId = 0 
	begin
		INSERT INTO [dbo].[CWI_Address]
				   ([AddressLine1]
				   ,[AddressLine2]
				   ,[CountryID]
				   ,[StateID]
				   ,[City]
				   ,[Zip]
				   ,[WorkPhone]
				   ,[WorkExtn]
				   ,[WorkFax]
				   ,[CreatedBy]
				   ,[CreatedOn]
				   ,[ModifiedBy]
				   ,[ModifiedOn])
			 VALUES
				   (
				   @AddressLine1,
					@AddressLine2,
					@CountryID,
					@StateID,
					@City,
					@Zip,
					@WorkPhone,
					@WorkExtn,
					@WorkFax,
					@author,
					getdate(),
					@author,
					getdate()
					)

		SET @AddressId = SCOPE_IDENTITY()
		RETURN
	end

	UPDATE [dbo].[CWI_Address]
   SET [AddressLine1] = @AddressLine1
      ,[AddressLine2] = @AddressLine2
      ,[CountryID] = @CountryID
      ,[StateID] = @StateID
      ,[City] = @City
      ,[Zip] = @Zip
      ,[WorkPhone] = @WorkPhone
      ,[WorkExtn] = @WorkExtn
      ,[WorkFax] = @WorkFax
      ,[ModifiedBy] = @Author
      ,[ModifiedOn] = GETDATE()
 WHERE Id = @addressId
END

' 
END
GO
