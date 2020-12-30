DELIMITER $$

CREATE OR REPLACE TRIGGER tUpdateCityStats AFTER UPDATE ON addresses
FOR EACH ROW
BEGIN
    UPDATE citystats
        SET population = population - 1
        WHERE name = OLD.city;

    IF (cityExists(NEW.city) = 0) THEN
        CALL addCity(NEW.city);
    END IF;

    UPDATE citystats
        SET population = population + 1
        WHERE name = NEW.city;
END $$

CREATE OR REPLACE TRIGGER tAddCity BEFORE INSERT ON addresses
FOR EACH ROW
BEGIN
    IF (cityExists(NEW.city) = 0) THEN
        CALL addCity(NEW.city);
    END IF;

    UPDATE citystats CS
        SET CS.population = CS.population + 1
        WHERE name = NEW.city;
END $$

CREATE OR REPLACE TRIGGER tDeleteCitizenData BEFORE DELETE ON citizens
FOR EACH ROW
BEGIN
    DECLARE delPesel VARCHAR(11) DEFAULT OLD.pesel;

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
END $$

DELIMITER $$

CREATE OR REPLACE TRIGGER tExtractCitizenData AFTER INSERT ON citizens
FOR EACH ROW
BEGIN
    DECLARE newPesel VARCHAR(11) DEFAULT NEW.pesel;

    CALL addCitizenGender(newPesel);

    UPDATE genderstats GS
        JOIN genders G ON GS.gender = G.gender
        SET GS.quantity = GS.quantity + 1
        WHERE G.pesel = newPesel;

    IF (yearExists(extractYearOfBirth(newPesel)) = 0) THEN
        CALL addYear(extractYearOfBirth(newPesel));
    END IF;

    CALL addCitizenBirthday(newPesel);

    UPDATE yearstats YS
        JOIN birthdays B ON YS.year = B.yearOfBirth
        SET YS.quantity = YS.quantity + 1
        WHERE B.pesel = newPesel;
END $$

DELIMITER ;

SHOW TRIGGERS;
