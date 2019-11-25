@ECHO OFF
set "PGPASSWORD=pass"
psql --dbname=datahome --port=6666 --username=user --host=localhost --file=.\db\create.sql