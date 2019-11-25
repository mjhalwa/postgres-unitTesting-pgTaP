@ECHO OFF

SET USERNAME=testuser
SET DBNAME=testdb
SET PORT=8899
SET PASSWORD=1234
SET CONTAINERNAME=pg-unittest-projectname

SET CREATE_SQL=.\db\create.sql
SET FUNCTIONS_SQL=.\db\functions.sql
SET IMPORT_SQL=.\db\import.sql
SET TEMP_SQL=temp.sql

SET errorMSG=


REM ==================================
REM MAIN
REM checking command line input
if "%1"=="" goto help
if "%1"=="init" goto runInit
if "%1"=="connect" goto runConnect
if "%1"=="test" goto runTests
SET errorMsg=ERROR: unknown command "%1"
goto help


REM ==================================
REM HELP
:help
ECHO    === Postgres Database Unit Test Tool ===
ECHO.
ECHO  RUN
ECHO         run.bat COMMAND
ECHO.
ECHO  DESCRIPTION
ECHO         this script simplifies postgres database
ECHO         unit tests preparation and execution
ECHO.
ECHO         the script expects the following sql files
ECHO         to exist:
ECHO         - '%CREATE_SQL%'
ECHO               creates tables and constraints
ECHO         - '%FUNCTIONS_SQL%'
ECHO               creates functions, prerequisists (like enums)
ECHO         - '%IMPORT_SQL%'
ECHO               import test data into the tables
ECHO.
ECHO         the script expects test scripts to reside in
ECHO             ./tests/
ECHO.
ECHO  COMMANDS:
ECHO    init
ECHO        Hint: just database creation without tests
ECHO        1) removes container, if already existing
ECHO        2) creates the postgres docker container
ECHO        3) creates the database from all above files in order
ECHO           1. '%CREATE_SQL%'
ECHO           2. '%FUNCTIONS_SQL%'
ECHO           3. '%IMPORT_SQL%'
ECHO        4) finally stops the container
ECHO    connect
ECHO        Hint: either run init or test before this!
ECHO        1) starts the currently existing docker container
ECHO        2) connects to the database in order to debug
ECHO           - when done, close connection with '\q'
ECHO        3) after closing connection, stops container
ECHO    test
ECHO        1) runs init
ECHO        2) runs pgTap on the database (perform unit tests)
ECHO        3) finally stops the container
ECHO.
ECHO  REMARKS:
ECHO     script automatically fixes possible issues with encoding
ECHO     on window consoles for german UTF-8 characters for all
ECHO     psql calls
ECHO.
goto commonExit

REM ----------------------------------
REM INIT DATABASE CONTAINER
:runInit
CALL :createDatabase
docker stop %CONTAINERNAME%
ECHO.
ECHO == done
goto commonExit

REM ----------------------------------
REM CONNECT to the DATABASE
:runConnect
docker start %CONTAINERNAME%
SLEEP 2
set "PGPASSWORD=%PASSWORD%" && psql --username=%USERNAME% --dbname=%DBNAME% --host=localhost --port=%PORT%
docker stop %CONTAINERNAME%
ECHO.
ECHO == done
goto commonExit

REM ----------------------------------
REM UNIT TESTS execution
:runTests
docker start %CONTAINERNAME%
CALL :createDatabase
CALL :runUnitTests
docker stop %CONTAINERNAME%
ECHO.
ECHO == done
goto commonExit


REM ==================================
REM SUBROUTINES
REM ----------------------------------
REM create DATABASE
:createDatabase
ECHO.
ECHO == create fresh container
docker stop %CONTAINERNAME%
docker rm %CONTAINERNAME%
docker run --name %CONTAINERNAME% -e POSTGRES_USER=%USERNAME% -e POSTGRES_PASSWORD=%PASSWORD% -e POSTGRES_DB=%DBNAME% -p %PORT%:5432 -d postgres
SLEEP 2
CALL :insertDatabaseContent
goto :eof

REM ----------------------------------
REM run unit tests
:insertDatabaseContent
ECHO.
ECHO == add tables, functions, data, etc.
TYPE %CREATE_SQL% > %TEMP_SQL%
TYPE %FUNCTIONS_SQL% >> %TEMP_SQL%
TYPE %IMPORT_SQL% >> %TEMP_SQL%
SLEEP 2
set "PGPASSWORD=%PASSWORD%" && psql --username=%USERNAME% --dbname=%DBNAME% --host=localhost --port=%PORT% --file=%TEMP_SQL% --quiet
SLEEP 2
DEL %TEMP_SQL%
goto :eof

REM ----------------------------------
REM run unit tests
:runUnitTests
ECHO.
ECHO == run unit tests
docker run -it --rm --name pgtap --link %CONTAINERNAME%:db -e USER="%USERNAME%" -e DATABASE="%DBNAME%" -e PASSWORD="%PASSWORD%" -v %cd%\tests:/test hbpmip/pgtap:1.0.0-3
goto :eof



REM ==================================
REM EXIT
:commonExit
if NOT "%errorMsg%"=="" ECHO %errorMsg%