

/****** Object:  StoredProcedure [dbo].[prc_CWI_AppRaiseError]    Script Date: 4/25/2013 2:33:12 PM ******/
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'prc_CWI_AppRaiseError')
DROP PROCEDURE [dbo].[prc_CWI_AppRaiseError]
GO

/****** Object:  StoredProcedure [dbo].[prc_CWI_AppRaiseError]    Script Date: 4/25/2013 2:33:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[prc_CWI_AppRaiseError] 
	@inUserInfo varchar(200) = NULL,
    @inExtendedErrorText     varchar(MAX) =	NULL
AS
BEGIN



      INSERT CWI_ErrorLog  (SpName,
                        ErrorCode,                  
						ErrorMessage,
						ErrorSeverity,
						ErrorState,
						ErrorLine,          
                        UserName,
						                              
                        ExtendedErrorText)
      SELECT   SpName                  =	ERROR_PROCEDURE() ,
               ErrorCode               =	ERROR_NUMBER() ,
               ErrorMessage            =	ERROR_MESSAGE(),
			   ErrorSeverity		   =	ERROR_SEVERITY() ,
			   ErrorState			   =	ERROR_STATE() ,
			   ErrorLine			   =	ERROR_LINE(),
               UserInfoID              =	@inUserInfo,
               ExtendedErrorText       =	@inExtendedErrorText

END
GO

