DO $$ 
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') 
    LOOP 
        EXECUTE 'DROP TABLE IF EXISTS public.' || r.tablename || ' CASCADE';
    END LOOP; 
END $$;


DO $$ 
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tgname, tgrelid::regclass FROM pg_trigger 
              WHERE NOT tgisinternal) 
    LOOP 
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.tgname || ' ON ' || r.tgrelid;
    END LOOP; 
END $$;



-- Table: Organisation


CREATE TABLE Organisation (
    name VARCHAR(100) PRIMARY KEY
);

-- Table: Location
CREATE TABLE Location (
    name VARCHAR(100) PRIMARY KEY,
    sector VARCHAR(100),
    rating INT CHECK (rating BETWEEN 0 AND 100)
);

-- Table: Species
CREATE TABLE Species (
    sid SERIAL PRIMARY KEY,
    name VARCHAR(100),
    traits TEXT,
    avrage_lifespan INT
);

-- Table: Person
CREATE TABLE Person (
    pid SERIAL PRIMARY KEY,
    name VARCHAR(100),
    species INT,
    bornon VARCHAR(100),
    FOREIGN KEY (species) REFERENCES Species(sid),
    FOREIGN KEY (bornon) REFERENCES Location(name)
);

-- Table: Author
CREATE TABLE Author (
    id INT PRIMARY KEY,
    reputation INT,
    FOREIGN KEY (id) REFERENCES Person(pid)
);

-- Table: Vip
CREATE TABLE Vip (
    id INT PRIMARY KEY,
    importance INT,
    FOREIGN KEY (id) REFERENCES Person(pid)
);

-- Table: Trip
CREATE TABLE Trip (
    startDate DATE,
    endDate DATE,
    person INT,
    location VARCHAR(100),
    score INT CHECK (score BETWEEN 0 AND 100),
    PRIMARY KEY (startDate, endDate, person),
    FOREIGN KEY (person) REFERENCES Person(pid),
    FOREIGN KEY (location) REFERENCES Location(name),
    CHECK (startDate < endDate)
);

-- Table: Spacecraft
CREATE TABLE Spacecraft (
    name VARCHAR(100) PRIMARY KEY,
    capacity INT,
    amenities TEXT,
    organisation VARCHAR(100),
    FOREIGN KEY (organisation) REFERENCES Organisation(name)
);

-- Table: Entry
CREATE TABLE Entry (
    ied SERIAL PRIMARY KEY,
    title VARCHAR(200),
    text TEXT,
    author INT,
    CONSTRAINT unique_text_and_title UNIQUE (title, text)
);

-- Table: PersonEntry
CREATE TABLE PersonEntry (
    entry INT,
    vip INT,
    PRIMARY KEY (entry, vip),
    FOREIGN KEY (entry) REFERENCES Entry(ied),
    FOREIGN KEY (vip) REFERENCES Vip(id)
);

-- Table: LocationEntry
CREATE TABLE LocationEntry (
    entry INT,
    location VARCHAR(100),
    PRIMARY KEY (entry, location),
    FOREIGN KEY (entry) REFERENCES Entry(ied),
    FOREIGN KEY (location) REFERENCES Location(name)
);

-- Table: SpeciesEntry
CREATE TABLE SpeciesEntry (
    entry INT,
    species INT,
    PRIMARY KEY (entry, species),
    FOREIGN KEY (entry) REFERENCES Entry(ied),
    FOREIGN KEY (species) REFERENCES Species(sid)
);

-- Table: Planet
CREATE TABLE Planet (
    name VARCHAR(100) PRIMARY KEY,
    population BIGINT,
    FOREIGN KEY (name) REFERENCES Location(name)
);
-- Note: External constraint: Planet[name] ∈ Location[name]
-- and Spacestation[name] ∩ Planet[name] = ∅ will need to be enforced externally.

-- Table: SpaceStation
CREATE TABLE SpaceStation (
    name VARCHAR(100) PRIMARY KEY,
    purpose VARCHAR(200),
    speed INT,
    FOREIGN KEY (name) REFERENCES Location(name)
);
-- Note: External constraint: Spacestation[name] ∩ Planet[name] = ∅

-- Table: uses
CREATE TABLE uses (
    person INT,
    spacecraft VARCHAR(100),
    startDate DATE,
    endDate DATE,
    PRIMARY KEY (person, spacecraft, startDate, endDate),
    FOREIGN KEY (spacecraft) REFERENCES Spacecraft(name),
    FOREIGN KEY (person, startDate, endDate) REFERENCES Trip(person, startDate, endDate)
);
-- Note: External constraint: Location[name] ⊆ Planet[name] ∪ Spacestation[name]
-- and the disjointness of entries among PersonEntry, LocationEntry, SpeciesEntry 
-- require additional procedures or triggers.

-- Trigger functions to enforce external constraints
-- Ensure that a Location is either a Planet or a SpaceStation
CREATE OR REPLACE FUNCTION enforce_location_constraint() RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Planet WHERE name = NEW.name) 
       AND NOT EXISTS (SELECT 1 FROM SpaceStation WHERE name = NEW.name) THEN
        RAISE EXCEPTION 'Location % must be either a Planet or a SpaceStation', NEW.name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_location_constraint
AFTER INSERT OR UPDATE ON Location
DEFERRABLE INITIALLY DEFERRED  -- Defer check until end of transaction
FOR EACH ROW EXECUTE FUNCTION enforce_location_constraint();

-- Ensure that a Planet and a SpaceStation do not have the same name
CREATE OR REPLACE FUNCTION enforce_disjoint_planet_spacestation() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Planet WHERE name = NEW.name) 
       AND EXISTS (SELECT 1 FROM SpaceStation WHERE name = NEW.name) THEN
        RAISE EXCEPTION 'A Planet and a SpaceStation cannot have the same name: %', NEW.name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_disjoint_planet_spacestation
AFTER INSERT OR UPDATE ON Planet
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION enforce_disjoint_planet_spacestation();

CREATE CONSTRAINT TRIGGER check_disjoint_planet_spacestation_2
AFTER INSERT OR UPDATE ON SpaceStation
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION enforce_disjoint_planet_spacestation();

-- Ensure that an entry belongs only to one of PersonEntry, LocationEntry, or SpeciesEntry
CREATE OR REPLACE FUNCTION enforce_entry_disjointness() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM PersonEntry WHERE entry = NEW.entry) > 0 
       AND (SELECT COUNT(*) FROM LocationEntry WHERE entry = NEW.entry) > 0 THEN
        RAISE EXCEPTION 'Entry % exists in both PersonEntry and LocationEntry', NEW.entry;
    ELSIF (SELECT COUNT(*) FROM PersonEntry WHERE entry = NEW.entry) > 0 
          AND (SELECT COUNT(*) FROM SpeciesEntry WHERE entry = NEW.entry) > 0 THEN
        RAISE EXCEPTION 'Entry % exists in both PersonEntry and SpeciesEntry', NEW.entry;
    ELSIF (SELECT COUNT(*) FROM LocationEntry WHERE entry = NEW.entry) > 0 
          AND (SELECT COUNT(*) FROM SpeciesEntry WHERE entry = NEW.entry) > 0 THEN
        RAISE EXCEPTION 'Entry % exists in both LocationEntry and SpeciesEntry', NEW.entry;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_entry_disjointness_person
AFTER INSERT OR UPDATE ON PersonEntry
FOR EACH ROW EXECUTE FUNCTION enforce_entry_disjointness();

CREATE TRIGGER check_entry_disjointness_location
AFTER INSERT OR UPDATE ON LocationEntry
FOR EACH ROW EXECUTE FUNCTION enforce_entry_disjointness();

CREATE TRIGGER check_entry_disjointness_species
AFTER INSERT OR UPDATE ON SpeciesEntry
FOR EACH ROW EXECUTE FUNCTION enforce_entry_disjointness();



-- Insert Organisations
INSERT INTO Organisation (name) VALUES 
('The Hitchhiker''s Guide Publishing'),
('Vogon Bureaucracy'),
('Galactic Government');

BEGIN;

-- Insert Locations
INSERT INTO Location (name, sector, rating) VALUES 
('Earth', 'Sol Sector', 42),
('Magrathea', 'Deep Space', 90),
('Milliways', 'End of Time', 99),
('Vogon Homeworld', 'Vogosphere', 10),
('Betelgeuse V', 'Betelgeuse System', 75);

-- Insert Planets
INSERT INTO Planet (name, population) VALUES 
('Earth', 7800000000),
('Magrathea', 10000),
('Vogon Homeworld', 1000000000),
('Betelgeuse V', 0);

-- Insert SpaceStations
INSERT INTO SpaceStation (name, purpose, speed) VALUES 
('Milliways', 'Restaurant at the End of the Universe', 0);

COMMIT;

-- Insert Species
INSERT INTO Species (name, traits, avrage_lifespan) VALUES 
('Human', 'Mostly harmless', 80),
('Betelgeusian', 'Two heads, three arms', 150),
('Vogon', 'Terrible poetry, bureaucratic', 200),
('Magrathean', 'Planet builders', 5000),
('Pangalactic', 'Loves strong drinks', 120);

-- Insert Persons
INSERT INTO Person (name, species, bornon) VALUES 
('Arthur Dent', 1, 'Earth'),
('Ford Prefect', 2, 'Betelgeuse V'),
('Zaphod Beeblebrox', 2, 'Betelgeuse V'),
('Slartibartfast', 4, 'Magrathea'),
('Prostetnic Vogon Jeltz', 3, 'Vogon Homeworld');

-- Insert VIPs
INSERT INTO Vip (id, importance) VALUES 
(3, 100), -- Zaphod Beeblebrox (Ex-Galactic President)
(4, 85), -- Slartibartfast (Award-winning planet designer)
(5, 50); -- Vogon Jeltz (Commander of Destructor Fleet)

-- Insert Authors
INSERT INTO Author (id, reputation) VALUES 
(2, 90); -- Ford Prefect (Field Researcher for the Guide)

-- Insert Trips
INSERT INTO Trip (startDate, endDate, person, location, score) VALUES 
('2024-01-01', '2024-02-01', 1, 'Milliways', 98), -- Arthur visiting Milliways
('2024-03-01', '2024-04-01', 3, 'Magrathea', 100), -- Zaphod visiting Magrathea
('2024-05-01', '2024-06-01', 2, 'Earth', 42), -- Ford Prefect visiting Earth
('2024-05-01', '2024-06-01', 5, 'Earth', 42); -- Vogon Jeltz visiting Earth to destroy it

-- Insert Spacecraft
INSERT INTO Spacecraft (name, capacity, amenities, organisation) VALUES 
('Heart of Gold', 10, 'Infinite Improbability Drive, Luxury', 'Galactic Government'),
('Vogon Destructor Ship', 500, 'Bureaucracy, Bad Poetry', 'Vogon Bureaucracy');

-- Insert Entries (Guide Articles)
INSERT INTO Entry (title, text, author) VALUES 
('Earth', 'Mostly Harmless.', 2),
('The Infinite Improbability Drive', 'A revolutionary means of crossing interstellar distances in a mere nothingth of a second.', 2),
('The Pan Galactic Gargle Blaster', 'The best drink in existence.', 2),
('Vogon Poetry', 'The third worst poetry in the universe.', 2);



-- Insert PersonEntry (Entries about VIPs)
INSERT INTO PersonEntry (entry, vip) VALUES 
(3, 3); -- Zaphod Beeblebrox in an article

-- Insert LocationEntry (Entries about Locations)
INSERT INTO LocationEntry (entry, location) VALUES 
(1, 'Earth'),
(2, 'Milliways');

-- Insert SpeciesEntry (Entries about Species)
INSERT INTO SpeciesEntry (entry, species) VALUES 
(4, 3); -- Vogon Poetry

-- Insert Uses (Person using a Spacecraft)
INSERT INTO uses (person, spacecraft, startDate, endDate) VALUES 
(1, 'Heart of Gold', '2024-01-01', '2024-02-01'),
(3, 'Heart of Gold', '2024-03-01', '2024-04-01'),
(5, 'Vogon Destructor Ship', '2024-05-01', '2024-06-01');
