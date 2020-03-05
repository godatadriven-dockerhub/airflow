#!/bin/bash

# Determine AIRFLOW_HOME
export AIRFLOW_HOME=$(python -c "from __future__ import print_function; from distutils.sysconfig import get_python_lib; print(get_python_lib())")/airflow
echo "Airflow is installed in $AIRFLOW_HOME"

# Install custom debian packages if packages.txt is present
if [ -f /dependencies/packages.txt ]; then\
    echo "Installing custom debian packages from /dependencies/packages.txt"
    apt-get install -y $(awk '/^\s*[^#]/' /dependencies/packages.txt | sed 's/\r//g');\
fi

# Install custom python package if requirements.txt is present
if [ -f /dependencies/requirements.txt ]; then
    echo "Installing custom pip packages from /dependencies/requirements.txt"
    pip install --no-cache-dir -r /dependencies/requirements.txt
fi

# Install custom conda packages if environment.yml is present
if [ -f /dependencies/environment.yml ]; then
    echo "Installing custom conda packages from /dependencies/environment.yml"
    conda env update --file /dependencies/environment.yml -n root
fi

if [ -n "$WAIT_FOR" ]; then
	IFS=';' read -a HOSTPORT_ARRAY <<< "$WAIT_FOR"
	for HOSTPORT in "${HOSTPORT_ARRAY[@]}"
	do
		WAIT_FOR_HOST=${HOSTPORT%:*}
		WAIT_FOR_PORT=${HOSTPORT#*:}
		  
		echo Waiting for $WAIT_FOR_HOST to listen on $WAIT_FOR_PORT...
		while ! nc -z $WAIT_FOR_HOST $WAIT_FOR_PORT; do echo sleeping; sleep 2; done
	done
fi

ORIGINAL_COMMAND="$@"
AIRFLOW_COMMAND="$1"
shift

# Run custom script if /dependencies/pre_hook.sh exists
if [ -f /dependencies/pre_hook.sh ]; then
  echo "Executing /dependencies/pre_hook.sh"
  bash /dependencies/pre_hook.sh "$ORIGINAL_COMMAND"
fi

if [ "$AIRFLOW_COMMAND" == "upgradedb_webserver" ]; then
    AIRFLOW_VERSION=$(python -c "from __future__ import print_function; from airflow import __version__; print(__version__)")
    if [[ $AIRFLOW_VERSION == 2* ]]; then
        echo "Detected Airflow version 2.*"
        airflow db upgrade
    else
        echo "Detected Airflow version 1.*"
        airflow upgradedb
    fi
    AIRFLOW_COMMAND="webserver"
fi

# Run custom script if /dependencies/post_hook.sh exists
if [ -f /dependencies/post_hook.sh ]; then
  echo "Executing /dependencies/post_hook.sh"
  bash /dependencies/post_hook.sh "$ORIGINAL_COMMAND"
fi

exec airflow $AIRFLOW_COMMAND "$@"