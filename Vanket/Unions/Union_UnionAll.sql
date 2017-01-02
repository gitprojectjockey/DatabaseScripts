--Combining the rows of MasterZipCodesCastleRock and MasterZipCodesDenver using UNION.
--UNION removes duplicate rows if any before combining the two result sets into one.
Select  mzcr.CodeName from MasterZipCodesCastleRock mzcr
UNION
Select  mzd.CodeName from MasterZipCodesDenver mzd

--Combining the rows of MasterZipCodesCastleRock and MasterZipCodesDenver using UNION.
--UNION ALL DOES NOT remove duplicate rows if any before combining the two result sets into one.
Select  mzcr.CodeName from MasterZipCodesCastleRock mzcr
UNION all
Select  mzd.CodeName from MasterZipCodesDenver mzd