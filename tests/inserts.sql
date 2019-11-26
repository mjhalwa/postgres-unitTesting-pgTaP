BEGIN;
SELECT plan( 5 );

SELECT lives_ok(
    $$
    SELECT addSpecies('{"mouse"}');
    $$,
    'should not error a new valid species');
-- Warning: `mouse` is now inserted! keep that in mind for the next functions

SELECT lives_ok(
    $$
    SELECT addSpecies('{"bear","lion"}')
    $$,
    'should not error multiple new valid species');

SELECT throws_ok(
    $$
    SELECT addSpecies('{"dog"}')
    $$,
    23505, 'duplicate key value violates unique constraint "species_name_key"',
    'for a single dublicate species');

SELECT throws_ok(
    $$
    SELECT addSpecies('{"dog","donkey"}')
    $$,
    23505, 'duplicate key value violates unique constraint "species_name_key"',
    'for any dublicate within multiple species');

SELECT throws_ok(
    $$
    SELECT addSpecies('{"dog","cat"}')
    $$,
    23505, 'duplicate key value violates unique constraint "species_name_key"',
    'for all dublicate within multiple species');

SELECT * FROM finish();
ROLLBACK;