DELIMITER $$

CREATE OR REPLACE PROCEDURE printPersonalData (pesel VARCHAR(11))
BEGIN
    DECLARE name VARCHAR(32);
    DECLARE surname VARCHAR(32);
    DECLARE city VARCHAR(32);
    DECLARE street VARCHAR(32);
    DECLARE house INT;
    DECLARE flat INT;

    IF (citizenExists(pesel)) THEN
        SET name = getCitizenName(pesel);
        SET surname = getCitizenSurname(pesel);
        SET city = getCitizenCity(pesel);
        SET street = getCitizenStreet(pesel);
        SET house = getCitizenHouse(pesel);
        SET flat = getCitizenFlat(pesel);

        SELECT CONCAT(name, ' ', surname, ', ', city,  ' ', street, ' ', house, ' ', flat);
    ELSE
        SELECT 'This citizen does not exist.';
    END IF;
END $$

CREATE OR REPLACE PROCEDURE addCitizen
    (pesel VARCHAR(11), password VARCHAR(32), status VARCHAR(32),
    name VARCHAR(32), surname VARCHAR(32), city VARCHAR(32), street VARCHAR(32),
    house INT, flat INT)
BEGIN
    SET AUTOCOMMIT = 0;
    START TRANSACTION;
        IF (pesel REGEXP '^[0-9]+$' AND LENGTH(pesel) = 11 AND citizenExists(pesel) = 0) THEN
            PREPARE stmt FROM 'INSERT INTO citizens VALUES (?, ?, ?)';
            EXECUTE stmt USING pesel, name, surname;
            DEALLOCATE PREPARE stmt;

            CALL addCitizenPassword(pesel, MD5(password));
            CALL addCitizenStatus(pesel, status);
            CALL addCitizenAddress(pesel, city, street, house, flat);
        END IF;
    COMMIT;
END $$

CREATE OR REPLACE PROCEDURE addCitizenPassword (pesel VARCHAR(11), password VARCHAR(32))
BEGIN
    PREPARE stmt FROM 'INSERT INTO passwords VALUES (?, ?)';
    EXECUTE stmt USING pesel, password;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenStatus (pesel VARCHAR(11), status VARCHAR(32))
BEGIN
    PREPARE stmt FROM 'INSERT INTO statuses VALUES (?, ?)';
    EXECUTE stmt USING pesel, status;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenAddress
    (pesel VARCHAR(11), city VARCHAR(32), street VARCHAR(32), house INT, flat INT)
BEGIN
    PREPARE stmt FROM 'INSERT INTO addresses VALUES (?, ?, ?, ?, ?)';
    EXECUTE stmt USING pesel, city, street, house, flat;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenGender (pesel VARCHAR(11))
BEGIN
    DECLARE gender VARCHAR(32) DEFAULT extractGender(pesel);

    PREPARE stmt FROM 'INSERT INTO genders VALUES (?, ?)';
    EXECUTE stmt USING pesel, gender;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenBirthday (pesel VARCHAR(11))
BEGIN
    DECLARE dayOfBirth INT DEFAULT extractDayOfBirth(pesel);
    DECLARE monthOfBirth INT DEFAULT extractMonthOfBirth(pesel);
    DECLARE yearOfBirth INT DEFAULT extractYearOfBirth(pesel);

    PREPARE stmt FROM 'INSERT INTO birthdays VALUES (?, ?, ?, ?)';
    EXECUTE stmt USING pesel, dayOfBirth, monthOfBirth, yearOfBirth;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizen (pesel VARCHAR(11), status VARCHAR(32))
BEGIN
    IF (citizenExists(pesel) AND getStatus(pesel) = status) THEN
        PREPARE stmt FROM 'DELETE FROM citizens WHERE pesel = ?';
        EXECUTE stmt USING pesel;
        DEALLOCATE PREPARE stmt;
        SELECT 'This citizen has been deleted.';
    ELSE
        SELECT 'This citizen does not exist or cant be deleted.';
    END IF;
END $$

CREATE OR REPLACE PROCEDURE updateCityStats (oldCity VARCHAR(32), newCity VARCHAR(32))
BEGIN
    SET AUTOCOMMIT = 0;
    START TRANSACTION;

    UPDATE citystats
        SET population = population - 1
        WHERE name = oldCity;
    UPDATE citystats
        SET population = population + 1
        WHERE name = newCity;

    COMMIT;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenData (delPesel VARCHAR(11))
BEGIN
    SET AUTOCOMMIT = 0;
    START TRANSACTION;

    DELETE FROM passwords WHERE pesel = delPesel;
    DELETE FROM statuses WHERE pesel = delPesel;

    UPDATE yearstats YS
        JOIN birthdays B ON YS.year = B.yearOfBirth
        SET YS.quantity = YS.quantity - 1
        WHERE B.pesel = delPesel;
    DELETE FROM birthdays WHERE pesel = delPesel;

    UPDATE genderstats GS
        JOIN genders G ON GS.gender = G.gender
        SET GS.quantity = GS.quantity - 1
        WHERE pesel = delPesel;
    DELETE FROM genders WHERE pesel = delPesel;

    UPDATE citystats CS
        JOIN addresses A ON CS.name = A.city
        SET CS.population = CS.population - 1
        WHERE A.pesel = delPesel;
    DELETE FROM addresses WHERE pesel = delPesel;

    COMMIT;
END $$

CREATE OR REPLACE PROCEDURE extractCitizenData (newPesel VARCHAR(11))
BEGIN
    SET AUTOCOMMIT = 0;
    START TRANSACTION;

    UPDATE citystats CS
        JOIN addresses A ON CS.name = A.city
        SET CS.population = CS.population + 1
        WHERE A.pesel = newPesel;

    CALL addCitizenGender(newPesel);
    UPDATE genderstats GS
        JOIN genders G ON GS.gender = G.gender
        SET GS.quantity = GS.quantity + 1
        WHERE G.pesel = newPesel;

    CALL addCitizenBirthday(newPesel);
    UPDATE yearstats YS
        JOIN birthdays B ON YS.year = B.yearOfBirth
        SET YS.quantity = YS.quantity + 1
        WHERE B.pesel = newPesel;

    COMMIT;
END $$

DELIMITER ;