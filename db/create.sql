DROP TABLE IF EXISTS People, Animals, Species;

CREATE TABLE Species (
    id          SERIAL      PRIMARY KEY,
    name        TEXT        UNIQUE
);

CREATE TABLE Animals (
    id          SERIAL      PRIMARY KEY,
    speciesId   INT         REFERENCES species(id),
    name        TEXT
);

CREATE TABLE People (
    id       SERIAL     PRIMARY KEY,
    name     TEXT,
    age      INT    CHECK(age >= 0 AND age <= 120),
    animalId INT    REFERENCES animals(id)
);
