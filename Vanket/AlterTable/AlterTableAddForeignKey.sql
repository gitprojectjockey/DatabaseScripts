alter table Person
add constraint Person_GenderId_FK foreign key(Gender) references Gender(Id)