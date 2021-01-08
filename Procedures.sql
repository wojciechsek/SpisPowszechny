DELIMITER $$

CREATE OR REPLACE PROCEDURE addCity(IN city VARCHAR(32))
BEGIN
    INSERT INTO citystats (name, population)
    VALUES (city, 0);
END $$

CREATE OR REPLACE PROCEDURE addYear(IN ayear INT)
BEGIN
    INSERT INTO yearstats (year, quantity)
    VALUES (ayear, 0);
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenPassword(IN delPesel VARCHAR(11))
BEGIN
    DELETE FROM passwords WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenStatus(IN delPesel VARCHAR(11))
BEGIN
    DELETE FROM statuses WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenGender(IN delPesel VARCHAR(11))
BEGIN
    DELETE FROM genders WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenBirthday(IN delPesel VARCHAR(11))
BEGIN
    DELETE FROM birthdays WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE deleteCitizenAddress(IN delPesel VARCHAR(11))
BEGIN
    DELETE FROM addresses WHERE pesel = delPesel;
END $$

CREATE OR REPLACE PROCEDURE changeAddress(IN pesel VARCHAR(11), IN city VARCHAR(32), IN street VARCHAR(32), IN house INT, IN flat INT)
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

CREATE OR REPLACE PROCEDURE changePassword(IN pesel VARCHAR(11), IN oldPassword VARCHAR(32), IN newPassword VARCHAR(32))
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

CREATE OR REPLACE PROCEDURE printPersonalData(IN pesel VARCHAR(11), OUT result VARCHAR(200))
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

        SELECT CONCAT(name, ' ', surname, ', ', city,  ' ', street, ' ', house, ' ', flat) INTO result;
    ELSE
        SELECT 'This citizen does not exist.' INTO result;
    END IF;
END $$

CREATE OR REPLACE PROCEDURE addCitizen
    (IN pesel VARCHAR(11), IN password VARCHAR(32), IN status VARCHAR(32),
    IN name VARCHAR(32), IN surname VARCHAR(32), IN city VARCHAR(32), IN street VARCHAR(32),
    IN house INT, IN flat INT)
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

CREATE OR REPLACE PROCEDURE addCitizenPassword(IN pesel VARCHAR(11), IN password VARCHAR(32))
BEGIN
    PREPARE stmt FROM 'INSERT INTO passwords VALUES (?, ?)';
    EXECUTE stmt USING pesel, password;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenStatus(IN pesel VARCHAR(11), IN status VARCHAR(32))
BEGIN
    PREPARE stmt FROM 'INSERT INTO statuses VALUES (?, ?)';
    EXECUTE stmt USING pesel, status;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenAddress
    (IN pesel VARCHAR(11), IN city VARCHAR(32), IN street VARCHAR(32), IN house INT, IN flat INT)
BEGIN
    PREPARE stmt FROM 'INSERT INTO addresses VALUES (?, ?, ?, ?, ?)';
    EXECUTE stmt USING pesel, city, street, house, flat;
    DEALLOCATE PREPARE stmt;
END $$

CREATE OR REPLACE PROCEDURE addCitizenGender(IN apesel VARCHAR(11))
BEGIN
    INSERT INTO genders VALUES (pesel, extractGender(apesel));
END $$

CREATE OR REPLACE PROCEDURE addCitizenBirthday(IN apesel VARCHAR(11))
BEGIN
    INSERT INTO birthdays VALUES (apesel, extractDayOfBirth(apesel),
                                  extractMonthOfBirth(apesel), extractYearOfBirth(apesel));
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