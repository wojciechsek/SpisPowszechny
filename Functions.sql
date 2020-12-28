DELIMITER $$
CREATE OR REPLACE FUNCTION getCitizenDayOfBirth (pesel VARCHAR(11)) RETURNS INT
BEGIN
     RETURN (SELECT B.dayOfBirth
        FROM birthdays B
        WHERE B.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION getCitizenMonthOfBirth (pesel VARCHAR(11)) RETURNS INT
BEGIN
    RETURN (SELECT B.monthOfBirth
        FROM birthdays B
        WHERE B.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION getCitizenYearOfBirth (pesel VARCHAR(11)) RETURNS INT
BEGIN
    RETURN (SELECT B.yearOfBirth
        FROM birthdays B
        WHERE B.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION getCitizenCity (pesel VARCHAR(11)) RETURNS VARCHAR(32)
BEGIN
    RETURN (SELECT A.city
        FROM addresses A
        WHERE A.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION getCitizenStreet (pesel VARCHAR(11)) RETURNS VARCHAR(32)
BEGIN
    RETURN (SELECT A.street
        FROM addresses A
        WHERE A.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION getCitizenHouse (pesel VARCHAR(11)) RETURNS INT
BEGIN
    RETURN (SELECT A.house
        FROM addresses A
        WHERE A.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION getCitizenFlat (pesel VARCHAR(11)) RETURNS INT
BEGIN
    RETURN (SELECT A.flat
        FROM addresses A
        WHERE A.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION extractGender (pesel VARCHAR(11)) RETURNS VARCHAR(32)
BEGIN
    IF (SUBSTRING(pesel, 10, 1) % 2 = 0) THEN
        RETURN 'Woman';
    ELSE
        RETURN 'Man';
    END IF;
END $$

CREATE OR REPLACE FUNCTION extractDayOfBirth (pesel VARCHAR(11)) RETURNS INT
BEGIN
    RETURN SUBSTRING(pesel, 5, 2);
END $$

CREATE OR REPLACE FUNCTION extractMonthOfBirth (pesel VARCHAR(11)) RETURNS INT
BEGIN
    IF (SUBSTRING(pesel, 3, 1) = '2' || SUBSTRING(pesel, 3, 1) = '3') THEN
        RETURN SUBSTRING(pesel, 3, 2) - 20;
    ELSE
        RETURN SUBSTRING(pesel, 3, 2);
    END IF;
END $$

CREATE OR REPLACE FUNCTION extractYearOfBirth (pesel VARCHAR(11)) RETURNS INT
BEGIN
    IF (SUBSTRING(pesel, 3, 1) = '2' || SUBSTRING(pesel, 3, 1) = '3') THEN
        RETURN LEFT(pesel, 2) + 2000;
    ELSE
        RETURN LEFT(pesel, 2) + 1900;
    END IF;
END $$

CREATE OR REPLACE FUNCTION citizenExists (pesel VARCHAR(11)) RETURNS INT
BEGIN
    RETURN EXISTS(SELECT * FROM citizens C WHERE C.pesel = pesel);
END $$

CREATE OR REPLACE FUNCTION cityExists (city VARCHAR(32)) RETURNS INT
BEGIN
    RETURN EXISTS(SELECT * FROM citystats C WHERE C.name = city);
END $$

CREATE OR REPLACE FUNCTION yearExists (year INT) RETURNS INT
BEGIN
    RETURN EXISTS(SELECT * FROM yearstats Y WHERE Y.year = year);
END $$
DELIMITER ;