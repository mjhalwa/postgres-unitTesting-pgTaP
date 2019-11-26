INSERT INTO Species (name) VALUES
    ('dog'),  --1
    ('cat'),  --2
    ('bird'); --3

INSERT INTO Animals (speciesId, name) VALUES
    (1, 'Pluto'),      -- 1
    (2, 'Garfield'),   -- 2
    (1, 'Oudey'),      -- 3
    (1, 'Rantanplan'), -- 4
    (3, 'Tweety'),     -- 5
    (2, 'Silvester'),  -- 6
    (1, 'Brutus'),     -- 7
    (2, 'Tom');        -- 8

INSERT INTO People (name, age, animalId) VALUES
    ('Michey Mouse', 40, 1),
    ('John Arbuckle', 42, 2),
    ('John Arbuckle', 42, 3),
    ('Lucky Luke', 32, 4),
    ('Granny', 79, 5),
    ('Granny', 79, 6),
    ('Granny', 79, 7),
    ('Mammy Two Shoes', 40, 1);
