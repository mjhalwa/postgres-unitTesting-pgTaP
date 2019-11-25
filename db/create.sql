DROP TABLE IF EXISTS people, animals, species;

CREATE TABLE species (
    id          SERIAL      PRIMARY KEY,
    name        TEXT        UNIQUE
);

CREATE TABLE animals (
    id          SERIAL      PRIMARY KEY,
    speciesId   INT         REFERENCES species(id),
    name        TEXT
);

CREATE TABLE people (
    id       SERIAL     PRIMARY KEY,
    name     TEXT,
    age      INT    CHECK(age >= 0 AND age <= 120),
    animalId INT    REFERENCES animals(id)
);
