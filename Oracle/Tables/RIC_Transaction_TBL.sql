DECLARE
   CURSOR TableColumns IS
      SELECT Column_Name
      FROM   user_tab_columns
      WHERE  Table_Name = 'RIC_TRANSACTION';
   sColsToAdd  varchar2(32000) := 
      ',DELIVERY,BOL,BILLTO,OTHER1,OTHER2,INVOICENUMBER,INVOICEDATE,';
   sSQLDML     varchar2(32000) := 'ALTER TABLE RIC_TRANSACTION ADD ('||chr(10);
   nStartPos   pls_integer     := 1;
   nLength     pls_integer     := 0;
BEGIN
   DBMS_OUTPUT.ENABLE(200000);
   DBMS_OUTPUT.PUT_LINE('Altering RIC_Transaction...');
   
   FOR rec IN TableColumns LOOP
      sColsToAdd := REPLACE(sColsToAdd,','||rec.Column_Name||',',',');  --> Removes columns from string that are already in the table
   END LOOP;

   DBMS_OUTPUT.PUT_LINE(sColsToAdd);
   sColsToAdd := REPLACE(sColsToAdd,'DELIVERY,'     ,'DELIVERY     DATE NULL,');
   sColsToAdd := REPLACE(sColsToAdd,'BOL,'          ,'BOL          VARCHAR2(20) NULL,');
   sColsToAdd := REPLACE(sColsToAdd,'BILLTO,'              ,'BILLTO              VARCHAR2(10) NULL,');
   sColsToAdd := REPLACE(sColsToAdd,'OTHER1,'              ,'OTHER1              VARCHAR2(50) NULL,');
   sColsToAdd := REPLACE(sColsToAdd,'OTHER2,'      ,'OTHER2      VARCHAR2(50) NULL,');
   sColsToAdd := REPLACE(sColsToAdd,'INVOICENUMBER,'      ,'INVOICENUMBER      VARCHAR2(30) NULL,');
   sColsToAdd := REPLACE(sColsToAdd,'INVOICEDATE,'      ,'INVOICEDATE      DATE NULL,');   
   sColsToAdd := RTRIM(sColsToAdd,',');
   sColsToAdd := LTRIM(sColsToAdd,',');
   
   IF length(sColsToAdd) > 0 THEN
      sSQLDML := sSQLDML ||sColsToAdd||')';
      DBMS_OUTPUT.PUT_LINE(SUBSTR('Adding:'||chr(10)||sColsToAdd,1,250));
      DBMS_OUTPUT.PUT_LINE(sSQLDML);
      EXECUTE IMMEDIATE (sSQLDML);
   ELSE
      DBMS_OUTPUT.PUT_LINE('No changes required.');
   END IF;
   
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SUBSTR(sSQLDML,1,250));
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/