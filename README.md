# Apache Airflow in Docker

Airflow docker container based on Miniconda

[![](https://images.microbadger.com/badges/image/godatadriven/airflow.svg)](https://microbadger.com/images/godatadriven/airflow "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/godatadriven/airflow.svg)](https://microbadger.com/images/godatadriven/airflow "Get your own version badge on microbadger.com") 

## Running the container
By default airflow --help is run:

```
docker run godatadriven/airflow 
```

To run the webserver, try our `upgradedb_webserver` command which first runs upgradedb (inits and upgrades the airflow database) before it starts the webserver

```
docker run godatadriven/airflow upgradedb_webserver
```

## Adding dependencies
When starting the container, the entrypoint script will look for additional dependencies to install in `/dependencies`.
It will install:

- Debian dependencies specified in `/dependencies/packages.txt`
- Pip dependencies specified in `/dependencies/requirements.txt`
- Conda dependencies specified in `/dependencies/environment.yml`

In the `dependencies_example` folder we've included some examples.

## Docker compose
We've build three compose files which use postgresql as a database.
 
- The first compose file starts the webserver and localexecutor as separate containers. 
- The second compose file uses celery to communicate with the executors.
- Finally the last compose file shows how to add additional dependencies at runtime.