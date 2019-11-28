BEGIN;
SELECT plan( 10 );

-- is() compares equality of arrays in order
SELECT is( '{1,2,3}'::INT[], '{1,2,3}'::INT[], 'should match same array correctly' );
SELECT isnt( '{1,2,3}'::INT[], '{3,2,1}'::INT[], 'does not match if same-content-arrays do not have same order' );

-- results_eq() compares equality of arrays in order
SELECT results_eq( $$ SELECT unnest('{1,2,3}'::INT[]) $$, '{1,2,3}'::INT[], 'should match arrays with content in same order' );
SELECT results_ne( $$ SELECT unnest('{1,2,3}'::INT[]) $$, '{3,2,1}'::INT[], 'does not match if same-content-arrays do not have same order' );

-- set_eq() compares equality, BUT allows different order
SELECT set_eq( $$ SELECT unnest('{1,2,3}'::INT[]) $$, '{1,2,3}'::INT[], 'should match arrays with content in same order' );
SELECT set_eq( $$ SELECT unnest('{1,2,3}'::INT[]) $$, '{3,2,1}'::INT[], 'finally matches arrays which have same content but are not in same order' );
-- unfortunately also matches if one XOR the other has dublicate entries
SELECT set_eq( $$ SELECT unnest('{1,2,3}'::INT[]) $$, '{3,2,1,1}'::INT[], 'should not match, if second array includes a dublicate of one value' );
SELECT set_eq( $$ SELECT unnest('{1,1,2,3}'::INT[]) $$, '{3,2,1}'::INT[], 'should not match, if first array includes a dublicate of one value' );
-- you may then test for no-dublicates with
SELECT results_eq( $$ SELECT DISTINCT unnest('{2,4,3,1}'::INT[]) AS tab ORDER BY tab $$,
                   $$ SELECT          unnest('{2,4,3,1}'::INT[]) AS tab ORDER BY tab $$,
                   'should match as array contains only unique elements' );
SELECT results_ne( $$ SELECT DISTINCT unnest('{2,1,3,1}'::INT[]) AS tab ORDER BY tab $$,
                   $$ SELECT          unnest('{2,1,3,1}'::INT[]) AS tab ORDER BY tab $$,
                   'should not match as array contains a dublicate element' );


SELECT * FROM finish();
ROLLBACK;