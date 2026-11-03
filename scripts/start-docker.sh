#!/bin/bash
echo "Starting Docker containers..."

mkdir -p deploy/docker
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env

docker compose -p telesrv -f docker-compose.yml up -d

sleep 10

echo "All containers are UP."
exit 0
