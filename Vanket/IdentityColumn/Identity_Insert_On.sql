--To explicitly supply a value for identity column
--1. First turn on identity insert - SET Identity_Insert tblPerson ON
--2. In the insert query specify the column list
--   Insert into tblPerson(PersonId, Name) values(2, 'John')
SET Identity_Insert PersonIdentity ON
