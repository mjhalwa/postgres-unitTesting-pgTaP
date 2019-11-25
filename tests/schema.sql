BEGIN;
SELECT plan( 3 );

SELECT has_table( 'people' );
SELECT has_table( 'animals' );
SELECT has_table( 'species' );
--SELECT has_table( 'blub' );

SELECT * FROM finish();
ROLLBACK;