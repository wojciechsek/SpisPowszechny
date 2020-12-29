CREATE OR REPLACE TABLE Citizens (
pesel VARCHAR(11),
name VARCHAR(32) NOT NULL,
surname VARCHAR(32) NOT NULL,
PRIMARY KEY (pesel)
);

CREATE OR REPLACE TABLE Birthdays (
pesel VARCHAR(11),
dayOfBirth INT UNSIGNED NOT NULL,
monthOfBirth INT UNSIGNED NOT NULL,
yearOfBirth INT UNSIGNED NOT NULL,
PRIMARY KEY (pesel),
FOREIGN KEY (pesel) REFERENCES  Citizens(pesel)
);

CREATE OR REPLACE TABLE CityStats (
name VARCHAR(32),
population INT NOT NULL,
PRIMARY KEY (name)
);

CREATE OR REPLACE TABLE Addresses (
pesel VARCHAR(11),
city VARCHAR(32) NOT NULL,
street INT UNSIGNED NOT NULL,
house INT UNSIGNED NOT NULL,
flat INT UNSIGNED,
PRIMARY KEY (pesel),
FOREIGN KEY (pesel) REFERENCES  Citizens(pesel),
FOREIGN KEY (city) REFERENCES  CityStats(name)
);

CREATE OR REPLACE TABLE GenderStats (
gender VARCHAR(32),
quantity INT UNSIGNED NOT NULL,
PRIMARY KEY (gender)
);

CREATE OR REPLACE TABLE Genders (
pesel VARCHAR(11),
gender VARCHAR(32) NOT NULL ,
PRIMARY KEY (pesel),
FOREIGN KEY (pesel) REFERENCES  Citizens(pesel),
FOREIGN KEY (gender) REFERENCES  GenderStats(gender)
);

CREATE OR REPLACE TABLE Passwords (
pesel VARCHAR(11),
password VARCHAR(32) NOT NULL,
PRIMARY KEY (pesel),
FOREIGN KEY (pesel) REFERENCES  Citizens(pesel)
);

CREATE OR REPLACE TABLE YearStats (
year INT UNSIGNED,
quantity INT UNSIGNED NOT NULL,
PRIMARY KEY (year)
);

CREATE OR REPLACE TABLE Statuses (
pesel VARCHAR(11),
status VARCHAR(32) NOT NULL,
PRIMARY KEY (pesel),
FOREIGN KEY (pesel) REFERENCES  Citizens(pesel)
);