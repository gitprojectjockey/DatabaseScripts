INSERT INTO Person (Id, Name, Email, Gender)
VALUES ((SELECT ISNULL(MAX(Id) + 1, 1) FROM Person), 'Eric', 'e@e.com', 1);