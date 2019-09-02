#!/bin/bash

AIRFLOW_VERSION=$(python -c "from __future__ import print_function; from airflow import __version__; print(__version__)")

if [[ $AIRFLOW_VERSION == 2* ]]; then
    echo "Detected Airflow version 2.0"
    airflow db init
else
   airflow initdb
fi

airflow webserver &
AIRFLOW_PID=$!

WAIT_FOR_HOST="127.0.0.1"
WAIT_FOR_PORT="8080"
  
echo Waiting for $WAIT_FOR_HOST to listen on $WAIT_FOR_PORT...
WEBSERVER_STATUS=1
for i in `seq 1 30`;
do
    if nc -z $WAIT_FOR_HOST $WAIT_FOR_PORT; then
        echo "process is listening, done"
        WEBSERVER_STATUS=0
        break
    else
        echo "still waiting"
        sleep 2
    fi
done

kill $AIRFLOW_PID
exit $WEBSERVER_STATUS
