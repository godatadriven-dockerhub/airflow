ARG PYTHON_VERSION=3.7
FROM godatadriven/miniconda:${PYTHON_VERSION}

ENV PYTHONDONTWRITEBYTECODE 1
ENV SLUGIFY_USES_TEXT_UNIDECODE yes

ARG BUILD_DATE
ARG AIRFLOW_VERSION
ARG AIRFLOW_EXTRAS=async,celery,crypto,jdbc,hdfs,hive,azure,gcp_api,emr,password,postgres,slack,ssh,kubernetes

LABEL org.label-schema.name="Apache Airflow ${AIRFLOW_VERSION}" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version=$AIRFLOW_VERSION

RUN set -x\
    && apt-get update \
    && apt-get install -y gcc g++ netcat git ca-certificates libpq-dev curl procps --no-install-recommends \
    && if [ "$AIRFLOW_VERSION" = "1.8.2" ]; then\
           conda install -y pip==9;\
       fi\
    && if [ "$AIRFLOW_VERSION" = "master" ]; then\
           pip install --no-cache-dir git+https://github.com/apache/airflow/#egg=apache-airflow[$AIRFLOW_EXTRAS];\
           curl -sL https://deb.nodesource.com/setup_8.x | bash - ;\
           apt-get install -y nodejs ;\
           cd /opt/miniconda3/lib/python3.6/site-packages/airflow/www/;\
           npm install;\
           npm run prod;\
           cd /;\
           apt-get remove -y --purge nodejs ;\
       elif [ "$AIRFLOW_VERSION" = "1.9.0" ]; then\
           pip install --no-cache-dir apache-airflow[$AIRFLOW_EXTRAS]==$AIRFLOW_VERSION "werkzeug<1.0.0";\
       elif [ -n "$AIRFLOW_VERSION" ]; then\
           pip install --no-cache-dir apache-airflow[$AIRFLOW_EXTRAS]==$AIRFLOW_VERSION;\
       else\
           pip install --no-cache-dir apache-airflow[$AIRFLOW_EXTRAS];\
       fi\
    && apt-get remove -y --purge gcc g++ git curl \
    && apt autoremove -y \
    && apt-get clean -y

COPY entrypoint.sh /scripts/
RUN chmod +x /scripts/entrypoint.sh

WORKDIR /root/airflow
VOLUME ["/root/airflow/dags", "/root/airflow/logs"]

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["--help"]
