DELIMITER $$

CREATE OR REPLACE TRIGGER tUpdateCityStats AFTER UPDATE ON addresses
FOR EACH ROW
BEGIN
    CALL updateCityStats(OLD.city, NEW.city);
END $$

CREATE OR REPLACE TRIGGER tDeleteCitizenData BEFORE DELETE ON citizens
FOR EACH ROW
BEGIN
    CALL deleteCitizenData(OLD.pesel);
END $$

CREATE OR REPLACE TRIGGER tExtractCitizenData AFTER INSERT ON citizens
FOR EACH ROW
BEGIN
    CALL extractCitizenData(NEW.pesel);
END $$

DELIMITER ;

SHOW TRIGGERS;