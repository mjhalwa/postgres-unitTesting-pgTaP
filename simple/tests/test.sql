BEGIN;
SELECT plan( 1 );

SELECT has_table( 'people' );  -- should be OK
--SELECT has_table( 'animals' ); -- should fail

SELECT * FROM finish();
ROLLBACK;