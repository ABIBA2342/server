#!/bin/bash
echo "Starting Docker containers..."

docker compose -f docker-compose.yml up -d

sleep 15

mkdir -p deploy/docker
touch deploy/docker/.env
echo "POSTGRES_PASSWORD=postgres" > deploy/docker/.env

echo "All containers are UP."
exit 0
