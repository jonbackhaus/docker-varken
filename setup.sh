#!/bin/bash
DOCKER_VOLUME_GRAFANA=varken_config_grafana

echo "> Spinning up services for the first time:"
docker-compose up -d influxdb
docker-compose up -d varken

echo "> Replacing varken.ini file with local copy:"
echo -n ">>> Stopping "
docker stop varken
echo ">>> Updating file..."
docker cp varken.ini varken:/config/
echo ">>> Starting container:"
docker-compose up -d varken

echo "> Fixing permissions for grafana volume:"
echo ">>> Starting container:"
docker-compose up -d grafana
echo -n ">>> Stopping "
docker stop grafana
echo ">>> Updating volume permissions..."
docker run -t --rm -v $DOCKER_VOLUME_GRAFANA:/config busybox chown -R 472:472 /config
echo ">>> Starting container:"
docker-compose up -d grafana

echo "> Importing the official Varken grafana dashboard:"
docker cp utilities/grafana_build.py varken:/config/grafana_build.py
docker exec -it varken python3 /config/grafana_build.py
