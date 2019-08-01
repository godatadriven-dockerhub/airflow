#!/bin/bash

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

AIRFLOW_COMMAND="$1"
shift

if [ "$AIRFLOW_COMMAND" == "upgradedb_webserver" ]; then
	airflow upgradedb
	
	AIRFLOW_COMMAND="webserver"
fi

exec airflow $AIRFLOW_COMMAND "$@"