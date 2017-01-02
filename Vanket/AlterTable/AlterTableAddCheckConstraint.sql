ALTER TABLE  Person 
ADD CONSTRAINT  CK_Person_Age  CHECK ( Age >=0 and Age <= 150)