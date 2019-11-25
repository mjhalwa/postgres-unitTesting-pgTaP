# Setup for Unit Testing a PostgreSQL Database

## Infos

pgTaP Tutorials:

- [pgTaP - homepage](https://pgtap.org/)
- [youtube - Susanne Schmidt](https://www.youtube.com/watch?v=d22xbB0nXeE)

docker image

- [docker image description](https://github.com/LREN-CHUV/docker-pgtap)
- [currently maintained docker image](https://hub.docker.com/r/hbpmip/pgtap)

## Installs

1. install `docker`
2. install `psql` (easiest to install postgres tools (without server tool))
3. pull the pgTap docker image

    ``` bash
    docker pull hbpmip/pgtap:1.0.0-3
    ```

4. run `run.bat`

### `run.bat` background info

1. run a `postgres`-container

    ``` bash
    docker run --name some-postgres -e POSTGRES_USER=user -e POSTGRES_PASSWORD=pass -e POSTGRES_DB=datahome -p 6666:5432 -d postgres
    ```

    __Important:__ Do configure all above environment variables! Connection issues arise, if you do not configure `user`, `password`, `databasename` and `port`!

    - container name: `some-postgres`
    - postgres database user name: `user`
    - password for the user `user`: `pass`
    - postgres database name: `datahome`
    - mapping internal port `5432` to external port: `6666` (if you don't set this, default is `5432`, which is also fine, but might interfere with other default-postgres ports)

    __Note:__ these settings are actually controlled via batch-variables, as they are required frequently. The actual settings in `run.bat` may differ from the above. See first lines of [`run.bat`](./run.bat)

2. connecting to the postgres container using `psql`, to validate its existance

    ``` batch
    REM on windows
    set "PGPASSWORD=%PASSWORD%" && psql --dbname=datahome --port=6666 --username=user --host=localhost
    ```

    ``` bash
    # on linux
    PGPASSWORD=$PASSWORD && psql --dbname=datahome --port=6666 --username=user --host=localhost
    ```

    __Note:__ we set `user`'s password for convience, so that `psql` does not ask again within this session

    __Note:__ you may also want to read about the usage of a password config file on [stackoverflow](https://stackoverflow.com/a/6216838/2195180) or [postgres docu - password file](https://www.postgresql.org/docs/current/libpq-pgpass.html)

    exit the container with `\q`

3. create database from `.sql` files (here only a single file for demonstration)

    ``` batch
    REM on windows
    set "PGPASSWORD=%PASSWORD%" && psql --dbname=datahome --port=6666 --username=user --host=localhost --file=.\db\create.sql
    ```

    ``` bash
    # on linux
    PGPASSWORD=$PASSWORD && psql --dbname=datahome --port=6666 --username=user --host=localhost --file=.\db\create.sql
    ```

    __Note:__ if you use same shell window, `PGPASSWORD` should still be stored, but there is no Error, if you re-set it to the same value

4. run `tests/*.sql` by mounting `tests` to pgTaP container and configure postgres database access

    ``` batch
    REM on windows
    docker run -i -t --rm --name pgtap --link some-postgres:db -e USER="user" -e DATABASE="datahome" -e PASSWORD="pass" -v %cd%\tests:/test hbpmip/pgtap:1.0.0-3
    ```

    ``` bash
    # on linux
    docker run -i -t --rm --name pgtap --link some-postgres:db -e USER="user" -e DATABASE="datahome" -e PASSWORD="pass" -v $pwd/tests:/test hbpmip/pgtap:1.0.0-3
    ```

    - __ACHTUNG__:
      - `HOST` do not configute, leave default at `db`
      - `PORT` do not configure, leave `5432`, otherwise does not work

        Note: we actually would expect to write `6666` the __external postgres container's port__, but then the pgTaP container cannot connect. Instead `5432` the __internal postgres container's port__ works. I could not figure out any particular reason, why the environment variable seems not to connnect to the container's external port.

    - in any case, outputs connection activity:

      ``` output
      Waiting for database...
      2019/11/22 11:27:04 Waiting for: tcp://db:5432
      ```

    - in case the postgres database does not run you get the response:

      ``` output
      2019/11/22 11:27:04 Problem with dial: dial tcp: lookup db on 192.168.65.1:53: server misbehaving. Sleeping 1s
      # ... and so on
      ```

    - in case all test succeeds writes

      ``` output
      2019/11/25 14:25:27 Connected to tcp://db:5432

      Running tests: /test/*.sql
      /test/schema.sql .. ok
      All tests successful.
      Files=1, Tests=3,  0 wallclock secs ( 0.02 usr +  0.00 sys =  0.02 CPU)
      Result: PASS
      ```

    - in case some tests fail

      __NOTE:__ to test a failing test, remove comment start `--` from 4th test line and edit `SELECT plan( 3 );` to `SELECT plan( 4 );`

      ``` output
      2019/11/25 14:22:21 Connected to tcp://db:5432

      Running tests: /test/*.sql
      /test/schema.sql .. 1/4
      # Failed test 4: "Table blub should exist"
      # Looks like you failed 1 test of 4
      /test/schema.sql .. Failed 1/4 subtests

      Test Summary Report
      -------------------
      /test/schema.sql (Wstat: 0 Tests: 4 Failed: 1)
      Failed test:  4
      Files=1, Tests=4,  0 wallclock secs ( 0.02 usr +  0.01 sys =  0.03 CPU)
      Result: FAIL
      ```

    - see [section on Troubleshooting](#troubleshooting) for other responses

## Structure

## Troubleshooting

1. test files are not copied to container
    - error message:

      ``` error
      Running tests: /test/*.sql
      Cannot detect source of '/test/*.sql'! at /usr/share/perl5/core_perl/TAP/Parser/IteratorFactory.pm line 261.
        TAP::Parser::IteratorFactory::detect_source(TAP::Parser::IteratorFactory=HASH(0x55f7fd065908), TAP::Parser::Source=HASH(0x55f7fcf2ecc0)) called at /usr/share/perl5/core_perl/TAP/Parser/IteratorFactory.pm line 211
        TAP::Parser::IteratorFactory::make_iterator(TAP::Parser::IteratorFactory=HASH(0x55f7fd065908), TAP::Parser::Source=HASH(0x55f7fcf2ecc0)) called at /usr/share/perl5/core_perl/TAP/Parser.pm line 472
        TAP::Parser::_initialize(TAP::Parser=HASH(0x55f7fcf2eb58), HASH(0x55f7fcc9a250)) called at /usr/share/perl5/core_perl/TAP/Object.pm line 55
        TAP::Object::new("TAP::Parser", HASH(0x55f7fcc9a250)) called at /usr/share/perl5/core_perl/TAP/Object.pm line 130
        TAP::Object::_construct(TAP::Harness=HASH(0x55f7fcba4328), "TAP::Parser", HASH(0x55f7fcc9a250)) called at /usr/share/perl5/core_perl/TAP/Harness.pm line 852
        TAP::Harness::make_parser(TAP::Harness=HASH(0x55f7fcba4328), TAP::Parser::Scheduler::Job=HASH(0x55f7fce94de8)) called at /usr/share/perl5/core_perl/TAP/Harness.pm line 651
        TAP::Harness::_aggregate_single(TAP::Harness=HASH(0x55f7fcba4328), TAP::Parser::Aggregator=HASH(0x55f7fcbbb070), TAP::Parser::Scheduler=HASH(0x55f7fce94d88)) called at /usr/share/perl5/core_perl/TAP/Harness.pm line 743
        TAP::Harness::aggregate_tests(TAP::Harness=HASH(0x55f7fcba4328), TAP::Parser::Aggregator=HASH(0x55f7fcbbb070), "/test/*.sql") called at /usr/share/perl5/core_perl/TAP/Harness.pm line 558
        TAP::Harness::__ANON__() called at /usr/share/perl5/core_perl/TAP/Harness.pm line 571
        TAP::Harness::runtests(TAP::Harness=HASH(0x55f7fcba4328), "/test/*.sql") called at /usr/share/perl5/core_perl/App/Prove.pm line 546
        App::Prove::_runtests(App::Prove::pgTAP=HASH(0x55f7fc6bf120), HASH(0x55f7fcb5a4c8), "/test/*.sql") called at /usr/share/perl5/core_perl/App/Prove.pm line 504
        App::Prove::run(App::Prove::pgTAP=HASH(0x55f7fc6bf120)) called at /usr/local/bin/pg_prove line 13
      ```

      __OR__ no error message, but 0 Files are tested:

      ``` txt
      Running tests: /test/*.sql
      Files=0, Tests=0,  0 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)
      Result: NOTESTS
      ```

    - debugging setup
        - try to mount `./tests` directory containing `*.sql` files for testing to container from `ubuntu` image, listing directory

            ``` bash
            docker run -it --rm -v %cd%\tests:/test ubuntu ls -la /test
            ```

        - you should see all files from `./tests` as files (permissions string should look like: `-rwxr-xr-x`, not `drwxr-xr-x`)

    - possible Errors
      1. volume is not bound properly, contained files are mapped as directories
      2. mount seems to be stuck on older version of filesystem
          - changing folder name to `ab` and also `-v %cd%\tests:/test` to `-v %cd%\ab:/test`, shows empty directory, but there should be a "blub.txt" inside
      3. after windows reboot and docker start: `test` is created empty, __BUT__ creating a file `blub` within the test directory:
          - does not show `blub` file in windows
          - after re-running a container fromt he image with same volume-bind the `blub` file still exists
          - after `docker volume prune` the `blub` file still exists
    - possible fixes
      1. `docker image prune` ... remove dangling images from docker
      2. `docker volume prune` ... remove dangling volumes from docker
      3. `docker system prune` ... remove all temporary and currently unused stuff from docker
      4. restart Docker
      5. check windows file system credentials are valid in docker settings
          - right click on docker symbol in status bar
          - select `Settings`
          - in the settings window select `Shared Drives`
          - select the drive in the table and click on `Reset credentials` in the lower left
          - (the checkbox unchecked last time I did it)
          - select the drive in the table again (in case it is not selected any more) and click on the `Apply` button
          - enter your valid credentials
          - try again to mount the volume, it should work now.
      6. restart windows
      7. Apply pending Docker Updates

2. check open Ports on windows:

    ``` batch
    netstat -an
    ```
