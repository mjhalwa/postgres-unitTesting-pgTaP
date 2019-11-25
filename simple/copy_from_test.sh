#!/bin/bash

function usage() { echo "Usage: $0 -h host -d database -p port -u username -w password -t 'tests/*.sql' [-v] [-a] [-k]" 1>&2; exit 1; }

VERBOSE=0
INSTALL=1
UNINSTALL=1
while getopts d:h:p:u:w:t:vakH OPTION
do
  case $OPTION in
    d)
      DATABASE=$OPTARG
      ;;
    h)
      HOST=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    w)
      PASSWORD=$OPTARG
      ;;
    t)
      TESTS=$OPTARG
      ;;
    v)
      VERBOSE=1
      ;;
    a)
      INSTALL=0
      ;;
    k)
      UNINSTALL=0
      ;;
    H)
      usage
      ;;
  esac
done
echo "Waiting for database..."
dockerize -timeout 240s -wait tcp://$HOST:$PORT
echo

echo "Running tests: $TESTS"
# install pgtap
if [[ $INSTALL == 1 ]] ; then
  if [[ $VERBOSE == 1 ]] ; then
    PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /pgtap/sql/pgtap.sql
  else
    PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /pgtap/sql/pgtap.sql > /dev/null 2>&1
  fi
  rc=$?

  # exit if pgtap failed to install
  if [[ $rc != 0 ]] ; then
    echo "pgTap was not installed properly. Unable to run tests!"
    exit $rc
  fi
fi

# run the tests
PGPASSWORD=$PASSWORD pg_prove -h $HOST -p $PORT -d $DATABASE -U $USER $TESTS
rc=$?

# uninstall pgtap
if [[ $UNINSTALL == 1 ]] ; then
  PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /pgtap/sql/uninstall_pgtap.sql > /dev/null 2>&1
fi

# exit with return code of the tests
exit $rc