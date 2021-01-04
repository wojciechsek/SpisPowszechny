DELIMITER $$

CREATE OR REPLACE PROCEDURE addCity(city VARCHAR(32))
BEGIN
    INSERT INTO citystats (name, population)
    VALUES (city, 0);
END $$

CREATE OR REPLACE PROCEDURE addYear(year INT)
BEGIN
    INSERT INTO yearstats (year, quantity)
    VALUES (year, 0);
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenPassword(delPesel VARCHAR(11))
BEGIN
    DELETE FROM passwords WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenStatus(delPesel VARCHAR(11))
BEGIN
    DELETE FROM statuses WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenGender(delPesel VARCHAR(11))
BEGIN
    DELETE FROM genders WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenBirthday(delPesel VARCHAR(11))
BEGIN
    DELETE FROM birthdays WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenAddress(delPesel VARCHAR(11))
BEGIN
    DELETE FROM addresses WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE changeAddress(pesel VARCHAR(11), city VARCHAR(32), street VARCHAR(32), house INT, flat INT)
BEGIN
    SET AUTOCOMMIT = 0;
    START TRANSACTION;
        IF (pesel REGEXP '^[0-9]+$' AND LENGTH(pesel) = 11 AND citizenExists(pesel) = 0) THEN
            PREPARE stmt FROM 'UPDATE addresses A
                               SET A.city = ?, A.street = ?, A.house = ?, A.flat = ?
                               WHERE A.pesel = ?;';
            EXECUTE stmt USING city, street, house, flat, pesel;
            DEALLOCATE PREPARE stmt;
        END IF;
    COMMIT;
END $$

CREATE OR REPLACE PROCEDURE changePassword(pesel VARCHAR(11), oldPassword VARCHAR(32), newPassword VARCHAR(32))
BEGIN
    SET AUTOCOMMIT = 0;
    START TRANSACTION;
        IF (pesel REGEXP '^[0-9]+$' AND LENGTH(pesel) = 11 AND checkPassword(pesel, oldPassword) = 1) THEN
            PREPARE stmt FROM 'UPDATE passwords P
                               SET P.password = ?
                               WHERE P.pesel = ?;';
            EXECUTE stmt USING newPassword, pesel;
            DEALLOCATE PREPARE stmt;
        END IF;
    COMMIT;
END $$

CREATE OR REPLACE PROCEDURE printPersonalData(pesel VARCHAR(11))
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

CREATE OR REPLACE PROCEDURE addCitizenPassword(pesel VARCHAR(11), password VARCHAR(32))
BEGIN
    PREPARE stmt FROM 'INSERT INTO passwords VALUES (?, ?)';
    EXECUTE stmt USING pesel, password;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenStatus(pesel VARCHAR(11), status VARCHAR(32))
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

CREATE OR REPLACE PROCEDURE addCitizenGender(pesel VARCHAR(11))
BEGIN
    INSERT INTO genders VALUES (pesel, extractGender(pesel));
END $$

CREATE OR REPLACE PROCEDURE addCitizenBirthday(pesel VARCHAR(11))
BEGIN
    INSERT INTO birthdays VALUES (pesel, extractDayOfBirth(pesel),
                                  extractMonthOfBirth(pesel), extractYearOfBirth(pesel));
END $$

CREATE OR REPLACE PROCEDURE deleteCitizen(IN pesel VARCHAR(11), IN status VARCHAR(32), OUT result VARCHAR(60))
BEGIN
    IF (citizenExists(pesel) AND getStatus(pesel) = status) THEN
        PREPARE stmt FROM 'DELETE FROM citizens WHERE pesel = ?';
        EXECUTE stmt USING pesel;
        DEALLOCATE PREPARE stmt;
        SELECT 'This citizen has been deleted.' INTO result;
    ELSE
        SELECT 'This citizen does not exist or cant be deleted.' INTO result;
    END IF;
END $$

CREATE OR REPLACE PROCEDURE displayCityStats (IN city VARCHAR(32), OUT result INT)
BEGIN
    SELECT CS.population INTO result
    FROM citystats CS
    WHERE CS.name = city;
END $$

CREATE OR REPLACE PROCEDURE displayGenderStats (IN sgender VARCHAR(32), OUT result INT)
BEGIN
    SELECT GS.quantity INTO result
    FROM genderstats GS
    WHERE GS.gender = sgender;
END $$

CREATE OR REPLACE PROCEDURE displayYearStats (IN syear INT, OUT result INT)
BEGIN
    SELECT YS.quantity INTO result
    FROM yearstats YS
    WHERE YS.year = syear;
END $$

CREATE OR REPLACE PROCEDURE displayStatus (IN spesel VARCHAR(11), OUT result VARCHAR(32))
BEGIN
    SELECT S.status INTO result
    FROM statuses S
    WHERE S.pesel = spesel;
END $$

CREATE OR REPLACE PROCEDURE changeStatus (IN spesel VARCHAR(11), IN newStatus VARCHAR(32))
BEGIN
    IF (getStatus(spesel) = 'Citizen' OR getStatus(spesel) = 'Bureaucrat') THEN
        UPDATE statuses
            SET status = newStatus
            WHERE pesel = spesel;
    END IF;
END $$

DELIMITER ;