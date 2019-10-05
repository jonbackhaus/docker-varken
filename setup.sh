#!/bin/bash
DOCKER_VOLUME_GRAFANA=varken_config_grafana

# Spin up services first time
docker-compose up -d influxdb
docker-compose up -d varken

# Replace varken.ini file
docker stop varken
docker cp varken.ini varken:/config/
docker-compose up -d varken

# Fix permissions for grafana
docker-compose up -d grafana
docker stop grafana
docker run -t -v $DOCKER_VOLUME_GRAFANA:/config --name helper busybox chown -R 472:472 /config
docker-compose up -d grafana

# Import the official grafana dashboard
docker cp utilities/grafana_build.py varken:/config/grafana_build.py
docker exec -t varken python3 /config/grafana_build.py
