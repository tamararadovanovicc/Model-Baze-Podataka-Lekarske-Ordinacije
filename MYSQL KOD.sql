-- ======================
-- Tabela: Pacijent
-- ======================
CREATE TABLE Pacijent (
    ID_pacijenta INT PRIMARY KEY AUTO_INCREMENT,
    LBO CHAR(11) UNIQUE NOT NULL CHECK (LBO REGEXP '^[0-9]{11}$'),
    Ime VARCHAR(50) NOT NULL CHECK (Ime REGEXP '^[A-ZĆČŠĐŽ][a-zćčšđž ]*$'),
    Prezime VARCHAR(50) NOT NULL CHECK (Prezime REGEXP '^[A-ZĆČŠĐŽ][a-zćčšđž ]*$'),
    JMBG CHAR(13) NOT NULL UNIQUE CHECK (JMBG REGEXP '^[0-9]{13}$'),
    Datum_rodjenja DATE NOT NULL ,
    Pol VARCHAR(7) NOT NULL CHECK (Pol IN ('muški', 'ženski')),
    Email VARCHAR(50) NULL CHECK (Email LIKE '%@%.%'),
    Telefon VARCHAR(20) NULL,
    Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT CK_Kontakt CHECK (Email IS NOT NULL OR Telefon IS NOT NULL)
);

-- ======================
-- Zdravstvena_knjizica
-- ======================
CREATE TABLE Zdravstvena_knjizica (
    ID_knjizice INT PRIMARY KEY AUTO_INCREMENT,
    ID_pacijenta INT NOT NULL UNIQUE,
    LBO CHAR(11) UNIQUE,
    Datum_izdavanja DATE NOT NULL,
    Datum_isteka DATE NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'važeća',
    Tip_osiguranja VARCHAR(50) NOT NULL DEFAULT 'RFZO' CHECK (Tip_osiguranja IN ('RFZO','Dopunsko','Privatno')),
    FOREIGN KEY (ID_pacijenta) REFERENCES Pacijent(ID_pacijenta)
);

-- ======================
-- Odeljenje
-- ======================
CREATE TABLE Odeljenje (
    ID_odeljenja INT PRIMARY KEY AUTO_INCREMENT,
    Naziv VARCHAR(100) NOT NULL,
    Lokacija VARCHAR(100) NOT NULL
);

-- ======================
-- Specijalizacija
-- ======================
CREATE TABLE Specijalizacija (
    ID_specijalizacije INT PRIMARY KEY AUTO_INCREMENT,
    Naziv VARCHAR(100) NOT NULL,
    Opis TEXT NOT NULL
);

-- ======================
-- Lekar
-- ======================
CREATE TABLE Lekar (
    ID_lekara INT PRIMARY KEY AUTO_INCREMENT,
    Ime VARCHAR(50) NOT NULL CHECK (Ime REGEXP '^[A-ZĆČŠĐŽ][a-zćčšđž ]*$'),
    Prezime VARCHAR(50) NOT NULL CHECK (Prezime REGEXP '^[A-ZĆČŠĐŽ][a-zćčšđž ]*$'),
    ID_specijalizacije INT NULL,
    ID_odeljenja INT NOT NULL DEFAULT 1,
    Broj_licence CHAR(11) UNIQUE NOT NULL CHECK (Broj_licence REGEXP '^OBG[A-Z0-9]{8}$'),
    Email VARCHAR(50) NOT NULL CHECK (Email LIKE '%@%.%'),
    Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (ID_specijalizacije) REFERENCES Specijalizacija(ID_specijalizacije),
    FOREIGN KEY (ID_odeljenja) REFERENCES Odeljenje(ID_odeljenja)
);

-- ======================
-- Smena
-- ======================
CREATE TABLE Smena (
    ID_smena INT PRIMARY KEY AUTO_INCREMENT,
    ID_lekara INT NULL,
    Datum_od DATE NOT NULL,
    Datum_do DATE NOT NULL,
    Tip_smena VARCHAR(20) NOT NULL CHECK (Tip_smena IN ('jutarnja','popodnevna')),
    Status VARCHAR(20) NOT NULL DEFAULT 'redovna' CHECK (Status IN ('redovna','zamena','godišnji')),
    ZamenaZaID INT NULL,
    Napomena VARCHAR(255) NULL,
    FOREIGN KEY (ID_lekara) REFERENCES Lekar(ID_lekara),
    FOREIGN KEY (ZamenaZaID) REFERENCES Lekar(ID_lekara)
);

-- ======================
-- Pacijent_karton
-- ======================
CREATE TABLE Pacijent_karton (
    ID_kartona INT PRIMARY KEY AUTO_INCREMENT,
    Broj_kartona INT UNIQUE NOT NULL,
    ID_pacijenta INT UNIQUE NOT NULL,
    LBO CHAR(11),
    ID_izabranog_lekara INT NULL,
    Datum_otvaranja DATE NOT NULL ,
    FOREIGN KEY (ID_pacijenta) REFERENCES Pacijent(ID_pacijenta),
    FOREIGN KEY (ID_izabranog_lekara) REFERENCES Lekar(ID_lekara)
);

-- ======================
-- Pregled
-- ======================
CREATE TABLE Pregled (
    ID_pregleda INT PRIMARY KEY AUTO_INCREMENT,
    ID_kartona INT,
    Broj_kartona INT NULL,
    LBO CHAR(11) NULL,
    ID_lekara INT NULL,
    Datum_vreme DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status_pregleda VARCHAR(20) NOT NULL DEFAULT 'zakazan' CHECK (Status_pregleda IN ('zakazan','obavljen','otkazan')),
    Simptomi TEXT DEFAULT 'nema simptoma',
    Napomena TEXT DEFAULT '',
    Datum_pocetka_bolovanja DATE NULL,
    Datum_zavrsetka_bolovanja DATE NULL,
    FOREIGN KEY (ID_kartona) REFERENCES Pacijent_karton(ID_kartona),
    FOREIGN KEY (ID_lekara) REFERENCES Lekar(ID_lekara)
);

-- ======================
-- Dijagnoza
-- ======================
CREATE TABLE Dijagnoza (
    ID_dijagnoze INT PRIMARY KEY AUTO_INCREMENT,
    Sifra VARCHAR(5) UNIQUE NOT NULL CHECK (Sifra REGEXP '^[A-Za-z][0-9]{2}(\\.[0-9])?$'),
    Naziv VARCHAR(100) NOT NULL,
    Opis TEXT NOT NULL
);

-- ======================
-- Pregled_dijagnoza (M:N)
-- ======================
CREATE TABLE Pregled_dijagnoza (
    ID_dijagnoze INT NOT NULL,
    ID_pregleda INT NOT NULL,
    PRIMARY KEY (ID_dijagnoze, ID_pregleda),
    FOREIGN KEY (ID_dijagnoze) REFERENCES Dijagnoza(ID_dijagnoze),
    FOREIGN KEY (ID_pregleda) REFERENCES Pregled(ID_pregleda)
);

-- ======================
-- Lek
-- ======================
CREATE TABLE Lek (
    ID_leka INT PRIMARY KEY AUTO_INCREMENT,
    Naziv VARCHAR(100) NOT NULL,
    ATC_kod CHAR(7) NOT NULL CHECK (ATC_kod REGEXP '^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$'),
    Proizvodjac VARCHAR(100) NOT NULL
);

-- ======================
-- Terapija
-- ======================
CREATE TABLE Terapija (
    ID_terapije INT PRIMARY KEY AUTO_INCREMENT,
    ID_pregleda INT NOT NULL,
    ID_leka INT NULL,
    Doziranje_trajanje VARCHAR(255) NOT NULL,
    Napomena TEXT NULL,
    FOREIGN KEY (ID_pregleda) REFERENCES Pregled(ID_pregleda),
    FOREIGN KEY (ID_leka) REFERENCES Lek(ID_leka)
);

-- ======================
-- Uput
-- ======================
CREATE TABLE Uput (
    ID_uputa INT PRIMARY KEY AUTO_INCREMENT,
    LBO CHAR(11) NULL,
    ID_pregleda INT NOT NULL,
    ID_lekara INT NOT NULL,
    ID_lekara_specijaliste INT NULL,
    ID_odeljenja_specijaliste INT NULL,
    Datum_izdavanja DATE NULL,
    Razlog_opis TEXT NOT NULL,
    Vazenje_uputa VARCHAR(20) NOT NULL,
    FOREIGN KEY (ID_pregleda) REFERENCES Pregled(ID_pregleda),
    FOREIGN KEY (ID_lekara_specijaliste) REFERENCES Lekar(ID_lekara)
);

-- ======================
-- Laboratorijski_nalaz
-- ======================
CREATE TABLE Laboratorijski_nalaz (
    ID_nalaza INT PRIMARY KEY AUTO_INCREMENT,
    LBO CHAR(11) NULL,
    ID_uputa INT NOT NULL,
    ID_pregleda INT NULL,
    ID_lekara INT NOT NULL,
    Datum DATE NOT NULL DEFAULT CURRENT_DATE(),
    Tip_analize VARCHAR(50) NOT NULL,
    Napomena TEXT NULL,
    FOREIGN KEY (ID_uputa) REFERENCES Uput(ID_uputa)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (Tip_analize IN ('Krvna slika sa leukocitarnom formulom','Biohemija','Urinokultura','Brisevi','Urin','Kopnokultura'))
);

-- ======================
-- Referentne_vrednosti
-- ======================
CREATE TABLE Referentne_vrednosti (
    ID_parametra INT PRIMARY KEY AUTO_INCREMENT,
    Naziv_parametra VARCHAR(50) NOT NULL UNIQUE,
    Donja_granica DECIMAL(10,2) NOT NULL,
    Gornja_granica DECIMAL(10,2) NOT NULL,
    Jedinica_mere VARCHAR(20) NOT NULL
);

-- ======================
-- Rezultat_analize
-- ======================
CREATE TABLE Rezultat_analize (
    ID_rezultata INT PRIMARY KEY AUTO_INCREMENT,
    ID_nalaza INT NOT NULL,
    Datum_izdavanja_rezultata DATE NOT NULL DEFAULT CURRENT_DATE(),
    ID_parametra INT NOT NULL,
    Vrednost DECIMAL(10,2) NOT NULL,
    Status VARCHAR(10) NULL,
    FOREIGN KEY (ID_nalaza) REFERENCES Laboratorijski_nalaz(ID_nalaza),
    FOREIGN KEY (ID_parametra) REFERENCES Referentne_vrednosti(ID_parametra)
);

-- ======================
-- Karton_log
-- ======================
CREATE TABLE Karton_log (
    Broj_kartona INT NOT NULL,
    LBO CHAR(11) NOT NULL,
    Ime VARCHAR(50) NOT NULL,
    Prezime VARCHAR(50) NOT NULL,
    JMBG CHAR(13) NOT NULL CHECK (JMBG REGEXP '^[0-9]{13}$'),
    ID_lekara INT NOT NULL,
    Ime_lekara VARCHAR(50) NOT NULL,
    Prezime_lekara VARCHAR(50) NOT NULL,
    Datum_otvaranja DATE NOT NULL,
    Datum_zatvaranja DATE NOT NULL DEFAULT CURRENT_DATE()
);
