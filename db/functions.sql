CREATE OR REPLACE FUNCTION addSpecies(
    speciesNames TEXT[]
  ) RETURNS VOID AS $$
    INSERT INTO Species (name)
      SELECT new.name
        FROM (
            SELECT unnest(speciesNames) AS name
        ) AS new;
  $$ LANGUAGE SQL;
