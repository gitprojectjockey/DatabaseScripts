create or replace PACKAGE TEIS_TRIPDATA_PKG AS
------------------------------------------------------------------------------------------
-- $Log: TEIS_TRIPDATA_PKG.sql  $

------------------------------------------------------------------------------------------
-- 03/26/2014  paolo      created for trip data transmit to TEIS db
--10/11/2014 jorge updated for trip retrieving data by SCAC
--11/10/2014 jorge added new fields invoicenumber and invoicedate
------------------------------------------------------------------------------------------
  TYPE output_cur IS REF CURSOR;
  
  deliverytype int := 19;
  /* TODO enter package declarations (types, exceptions, methods etc) here */

  PROCEDURE UPDATETRIPDETAIL (
     in_TrasactionId in RIC_TRANSACTION.TXID%TYPE
    ,in_DriverID in  RIC_TRANSACTION.DRIVERID%TYPE
    ,in_Tractor in  RIC_TRANSACTION.TRACTOR%TYPE
    ,in_BOLNo in  RIC_TRANSACTION.BOL%TYPE
    ,in_BillTo in  RIC_TRANSACTION.BILLTO%TYPE
    ,in_Other1 in  RIC_TRANSACTION.OTHER1%TYPE
    ,in_Other2 in  RIC_TRANSACTION.OTHER2%TYPE
    ,in_ModifiedBy in  RIC_TRANSACTION.MODIFIEDBY%TYPE
    ,in_Delivery in  RIC_TRANSACTION.DELIVERY%TYPE
    ,in_TripNo in RIC_TRANSACTION.TRIP%TYPE
     ,in_InvoiceNumber in RIC_TRANSACTION.INVOICENUMBER%TYPE
    ,in_InvoiceDate in RIC_TRANSACTION.INVOICEDATE%TYPE
  ,out_ErrorMsg OUT VARCHAR2);

PROCEDURE UPDATEDOCTYPE  (
       in_TrasactionId in  RIC_TRANSACTION.TXID%TYPE
      ,in_DocNumber in  RIC_DOCUMENT.DOCNUM%TYPE
      ,in_DocType in  RIC_DOCUMENT.DOCTYPE%TYPE
      ,out_ErrorMsg OUT VARCHAR2
      );

PROCEDURE GETTRIPDATA(
     out_Cursor                       OUT output_cur
    ,out_ErrorMsg OUT VARCHAR2
  )
;

  PROCEDURE GETTRIPDATABYSCAC(
   in_Scac                           VARCHAR2
  ,in_StartDate                     TIMESTAMP
  ,in_EndDate                       TIMESTAMP
  ,out_Cursor                       OUT output_cur 
  ,out_ErrorMsg                     OUT VARCHAR2
  );
  
  
PROCEDURE GETTRIPDATABYTXID(
   in_TxId                          RIC_TRANSACTION.TXID%TYPE
  ,out_Cursor                       OUT output_cur 
  ,out_ErrorMsg                     OUT VARCHAR2
  );
  
PROCEDURE GETDOCUMENTS(
   in_TxId                          RIC_TRANSACTION.TXID%TYPE
  ,out_Cursor                       OUT output_cur 
  ,out_ErrorMsg                     OUT VARCHAR2
  );

PROCEDURE UPDATETRANSMITTED  (
       in_TrasactionId in  RIC_TRANSACTION.TXID%TYPE
      ,out_ErrorMsg OUT VARCHAR2
      );
      
      
PROCEDURE StartRICTransaction (
      in_SourceID                IN       RIC_Source.SourceID%TYPE
    , in_TxTimestamp             IN       RIC_Transaction.TxTimestamp%TYPE
    , in_TxLocalTimestamp        IN       RIC_Transaction.TxLocalTimestamp%TYPE
    , in_AdjustedTimezoneCode    IN       RIC_Transaction.AdjustedTimezoneCode%TYPE
    , in_ReceivedUTC             IN       RIC_Transaction.ReceivedUTC%TYPE
    , in_NumDocs                 IN       RIC_Transaction.NumDocs%TYPE
    , in_Scac                    IN       RIC_Carrier.Scac%TYPE
    , in_ReferenceNumber         IN       RIC_Transaction.ReferenceNumber%TYPE
    , in_Trip                    IN       RIC_Transaction.Trip%TYPE
    , in_Tractor                 IN       RIC_Transaction.Tractor%TYPE
    , in_DriverID                IN       RIC_Transaction.DriverID%TYPE
    , out_Cursor                 OUT      output_cur
    , out_ErrorMsg               OUT      VARCHAR2
    );
    
PROCEDURE AddRICDocument (
      in_TxId                         IN   RIC_Document.TxId%TYPE
    , in_DocNum                       IN   RIC_Document.DocNum%TYPE
    , in_DocType                      IN   RIC_Document.DocType%TYPE
    , in_Path                         IN   RIC_Document.Path%TYPE
    , in_OrigFileName                 IN   RIC_Document.OrigFileName%TYPE
    , in_OrigFileSize                 IN   RIC_Document.OrigFileSize%TYPE
    , out_ErrorMsg                    OUT  VARCHAR2);    
    
--------------------------------------------------------------------------------
   PROCEDURE CompleteRICTransaction (
      in_TxID                    IN       RIC_Transaction.TxID%TYPE
    , in_AccessCode              IN       RIC_Transaction.AccessCode%TYPE
    , out_ErrorMsg               OUT      VARCHAR2)
    ;
 PROCEDURE SETTRANSMITTED(
  in_TxId    IN      RIC_TRANSACTION.TXID%TYPE 
  ,out_ErrorMsg OUT VARCHAR2
  );
END TEIS_TRIPDATA_PKG;
/