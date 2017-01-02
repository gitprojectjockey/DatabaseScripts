create or replace PACKAGE BODY TEIS_TRIPDATA_PKG AS
  PROCEDURE UPDATETRIPDETAIL(
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
  ,out_ErrorMsg OUT VARCHAR2)
    IS
    BEGIN
    UPDATE RIC_TRANSACTION SET
      DRIVERID=in_DriverID
      ,TRACTOR=in_Tractor
      ,BOL=in_BOLNo
      ,BILLTO=in_BillTo
      ,OTHER1=in_Other1
      ,OTHER2=in_Other2
      ,MODIFIEDBY=in_ModifiedBy
      ,MODIFIEDDATE=CURRENT_DATE
      ,DELIVERY=in_Delivery
      ,TRIP=in_TripNo
      ,INVOICENUMBER=in_InvoiceNumber
      ,INVOICEDATE=in_InvoiceDate
      WHERE TXID=in_TrasactionId;
 EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
    END UPDATETRIPDETAIL;

    PROCEDURE UPDATEDOCTYPE (
      in_TrasactionId in  RIC_TRANSACTION.TXID%TYPE
      ,in_DocNumber in  RIC_DOCUMENT.DOCNUM%TYPE
      ,in_DocType in  RIC_DOCUMENT.DOCTYPE%TYPE
      ,out_ErrorMsg OUT VARCHAR2
      )
    IS
    BEGIN
    UPDATE RIC_DOCUMENT SET DOCTYPE=in_DocType where TXID=in_TrasactionId and DOCNUM=in_DocNumber;
      EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
  END UPDATEDOCTYPE;
  
  PROCEDURE GETTRIPDATA(
   out_Cursor                       OUT output_cur 
    ,out_ErrorMsg OUT VARCHAR2
  )
  IS
    BEGIN
     OPEN out_Cursor FOR
     select
       t.TXID,c.SCAC,t.RECEIVED
      FROM
      RIC_TRANSACTION t
      inner join RIC_CARRIER c on t.CarrierId=c.CarrierId
      where c.DeliveryTypeID = 19 and t.transmitted is null and t.RECORDSTATUS IS NULL and rownum=1
      Order By t.TXID asc
;
 EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
  END GETTRIPDATA;
  
  PROCEDURE UPDATETRANSMITTED (
      in_TrasactionId in  RIC_TRANSACTION.TXID%TYPE
      ,out_ErrorMsg OUT VARCHAR2
      )
    IS
    BEGIN
    UPDATE RIC_TRANSACTION SET TRANSMITTED=SYSDATE() where TXID=in_TrasactionId;
      EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
  END UPDATETRANSMITTED; 
  
  PROCEDURE GETTRIPDATABYSCAC(
  in_Scac VARCHAR2
  ,in_StartDate TIMESTAMP
  ,in_EndDate TIMESTAMP
  ,out_Cursor                       OUT output_cur 
  ,out_ErrorMsg OUT VARCHAR2
  )
  IS
    BEGIN
     OPEN out_Cursor FOR
     SELECT 
       t.TXID,t.TXNUM,t.DriverID,t.Tractor,t.BOL,BillTo,t.Delivery,t.other1,t.other2,c.SCAC,t.RECEIVED, c.DELIVERYTYPEID,
                    t.MODIFIEDBY , t.MODIFIEDDATE, t.TRIP, t.NUMDOCS,t.INVOICENUMBER, t.INVOICEDATE
      FROM 
      RIC_TRANSACTION t
      INNER JOIN RIC_CARRIER c on t.CarrierId=c.CarrierId 
      INNER JOIN (SELECT regexp_substr(in_Scac,'[^,]+', 1, level) SCAC FROM dual
      CONNECT BY regexp_substr(in_Scac, '[^,]+', 1, level) IS NOT NULL
      ) s ON s.SCAC=c.SCAC
      WHERE c.DeliveryTypeID = 19 AND t.transmitted IS not NULL and t.RECEIVED BETWEEN in_StartDate AND in_EndDate
      ORDER BY t.TXID ASC ;
 EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
  END GETTRIPDATABYSCAC;
  
  
  PROCEDURE GETTRIPDATABYTXID(
  in_TxId    IN      RIC_TRANSACTION.TXID%TYPE
  ,out_Cursor                       OUT output_cur 
  ,out_ErrorMsg OUT VARCHAR2
  )
  IS
    BEGIN
     OPEN out_Cursor FOR
     SELECT 
       t.TXID,t.TXNUM,t.DriverID,t.Tractor,t.BOL,BillTo,t.Delivery,t.other1,t.other2,c.SCAC,t.RECEIVED, c.DELIVERYTYPEID,
                    t.MODIFIEDBY , t.MODIFIEDDATE, t.TRIP, t.NUMDOCS,t.SOURCEID, t.INVOICENUMBER, t.INVOICEDATE
      FROM 
      RIC_TRANSACTION t
      INNER JOIN RIC_CARRIER c on t.CarrierId=c.CarrierId 
      WHERE c.DeliveryTypeID = 19 AND t.transmitted IS not NULL and t.TXID = in_TxId
      ORDER BY t.TXID ASC ;
 EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
  END GETTRIPDATABYTXID;
  
  PROCEDURE GETDOCUMENTS(
  in_TxId    IN      RIC_TRANSACTION.TXID%TYPE
  ,out_Cursor                       OUT output_cur 
  ,out_ErrorMsg OUT VARCHAR2
  )
  IS
    BEGIN
     OPEN out_Cursor FOR
     SELECT t.txid, d.docnum, d.doctype, SUBSTR(path,(INSTR(REVERSE(path),'\')*-1)+1,INSTR(REVERSE(path),'\')) name, path 
      FROM RIC_TRANSACTION t 
      inner join RIC_DOCUMENT d on t.txid = d.txid
      where t.txid= in_TxId
      ORDER BY t.TXID ASC ;
 EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
  END GETDOCUMENTS;
  
  
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
    )
  
  IS
  
   -- Cursors --
      CURSOR ExecInfo
      IS
         SELECT car.CarrierID, src.ScannerID, src.LocationID
         FROM   RIC_Carrier car
              , RIC_Source src
         WHERE  src.SourceID = in_SourceID
         AND    car.scac = in_scac;

      ExecInfoRec     ExecInfo%ROWTYPE;
      
      -- Local variables --
      ReturnResult    RIC_Transaction_PKG.id_msg_rec;
      ReturnResultRec ReturnResult%ROWTYPE;
      nTxNum          RIC_Transaction.TxNum%TYPE;
      nTxID           RIC_Transaction.TxID%TYPE;
      sErrorMsg       VARCHAR2 (200);
      nKeyCount       PLS_INTEGER;
      
   BEGIN
      -- Lookup values required for execution --
      OPEN ExecInfo;

      FETCH ExecInfo
      INTO  ExecInfoRec;

      CLOSE ExecInfo;

      -- Get sequence for TxNum --
      SELECT RIC_TxNum_SEQ.NEXTVAL
      INTO   nTxNum
      FROM   DUAL;

      RIC_Transaction_PKG.TxInsert
                            (in_scac                      => in_scac
                           , in_LocationID                => ExecInfoRec.LocationID
                           , in_ScannerID                 => ExecInfoRec.ScannerID
                           , in_TxNum                     => nTxNum
                           , in_TxTimestamp               => in_TxTimestamp
                           , in_TxType                    => 12
                           , in_NumDocs                   => in_NumDocs
                           , in_RC                        => 0
                           , in_AccessCode                => NULL
                           , in_CarrierID                 => ExecInfoRec.CarrierID
                           , in_TxLocalTimestamp          => in_TxLocalTimestamp
                           , in_AdjustedTimezoneCode      => in_AdjustedTimezoneCode
                           , in_ReceivedUTC               => in_ReceivedUTC
                           , out_Cursor                   => ReturnResult
                           , in_OrigFileName              => NULL
                           , in_OrigFileExt               => NULL);

      FETCH ReturnResult
      INTO  nTxID, sErrorMsg;

      CLOSE ReturnResult;
      
      out_ErrorMsg := sErrorMsg;

      -- Seperately update the Trip items
      UPDATE RIC_Transaction
      SET ReferenceNumber = in_ReferenceNumber
        , DriverID        = in_DriverID
        , Trip            = NVL(in_Trip, Trip)
        , Tractor         = NVL(in_Tractor, Tractor)
      WHERE  TxID = nTxID;

      OPEN out_Cursor FOR
         SELECT nTxNum TxNum, nTxID TxID, sErrorMsg ErrorMsg
         FROM   DUAL;
   EXCEPTION
      
      WHEN OTHERS THEN
         sErrorMsg    := SUBSTR (SQLERRM, 1, 200);

         IF ReturnResult%ISOPEN THEN
            CLOSE ReturnResult;
         END IF;

         IF ExecInfo%ISOPEN THEN
            CLOSE ExecInfo;
         END IF;
         
         out_ErrorMsg := sErrorMsg;

         OPEN out_Cursor FOR
            SELECT nTxNum TxNum, nTxID TxID, sErrorMsg ErrorMsg
            FROM   DUAL;
  
  END;
  
  
PROCEDURE AddRICDocument (
      in_TxId                         IN   RIC_Document.TxId%TYPE
    , in_DocNum                       IN   RIC_Document.DocNum%TYPE
    , in_DocType                      IN   RIC_Document.DocType%TYPE
    , in_Path                         IN   RIC_Document.Path%TYPE
    , in_OrigFileName                 IN   RIC_Document.OrigFileName%TYPE
    , in_OrigFileSize                 IN   RIC_Document.OrigFileSize%TYPE
    , out_ErrorMsg                    OUT  VARCHAR2)
IS
      null_cursor    output_cur;
      cRecordStatus  RIC_Transaction.RecordStatus%Type;
BEGIN
      BEGIN
         SELECT RecordStatus
         INTO cRecordStatus
         FROM RIC_Transaction
         WHERE TxID = in_TxID;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            out_ErrorMsg := 'Transaction ID does not exist';
      END;

      IF cRecordStatus = 'PENDING' THEN
         RIC_Document_PKG.UpsertDocument (
            in_TxId         => in_TxID
          , in_DocNum       => in_DocNum
          , in_DocType      => in_DocType
          , in_Path         => in_Path
          , in_DocBarCode   => NULL
          , in_OrigFileName => in_OrigFileName
          , in_OrigFileSize => in_OrigFileSize
          , out_Cursor      => null_cursor);
          
         CLOSE null_cursor;
      ELSE
         out_ErrorMsg := 'Transaction is completed, cannot add more documents';
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         IF null_cursor%ISOPEN THEN
            FETCH null_cursor INTO out_ErrorMsg;
            CLOSE null_cursor;
         ELSE
            out_ErrorMsg := SQLERRM;
         END IF;
END;
  
  
  PROCEDURE CompleteRICTransaction (
      in_TxID                    IN       RIC_Transaction.TxID%TYPE
    , in_AccessCode              IN       RIC_Transaction.AccessCode%TYPE
    , out_ErrorMsg               OUT      VARCHAR2)
  IS
      INVALID_DOC_COUNT   EXCEPTION;
      nTransCnt           pls_integer;
      nDocCnt             pls_integer;
   BEGIN
      SELECT NumDocs, count(DocNum) Cnt
      INTO nTransCnt, nDocCnt
      FROM  RIC_Transaction  trn
          , RIC_Document     doc
      WHERE trn.TxID = doc.TxID
      AND   trn.TxID = in_TxID
      GROUP BY NumDocs;

      IF NVL(nTransCnt,0) != NVL(nDocCnt,-1) THEN
         RAISE INVALID_DOC_COUNT;
      END IF;

      UPDATE RIC_Transaction
      SET RecordStatus = NULL
        , AccessCode = in_AccessCode
      WHERE TxID = in_TxID;

      COMMIT;

   EXCEPTION
      WHEN INVALID_DOC_COUNT THEN
         out_ErrorMsg := 'Transaction number of docs ('||nvl(to_char(nTransCnt),'null')||') is not equal to total number of docs ('||nvl(to_char(nDocCnt),'null')||')';
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
         ROLLBACK;
END;
  PROCEDURE SETTRANSMITTED(
  in_TxId    IN      RIC_TRANSACTION.TXID%TYPE 
  ,out_ErrorMsg OUT VARCHAR2
  )
  IS
    BEGIN
    UPDATE RIC_TRANSACTION SET TRANSMITTED=SYSDATE WHERE TXID=in_TxId;
 EXCEPTION
      WHEN OTHERS THEN
         out_ErrorMsg := SQLERRM;
      RETURN;
  END SETTRANSMITTED;
END TEIS_TRIPDATA_PKG;
/