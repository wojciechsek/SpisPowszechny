INSERT INTO genderstats VALUES ('Woman', 0), ('Man', 0);

CALL addCitizen('00291400399', 'admin1', 'Admin', 'Paweł',
    'Cegieła', 'Wrocław', 'Świdnicka', 22, 7, @out_value);