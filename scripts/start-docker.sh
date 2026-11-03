#!/bin/bash
echo "Starting Docker containers..."

docker compose -p postgres -f docker-compose.yml up -d

sleep 10

docker rename telesrv-postgres postgres
docker rename telesrv-redis redis
docker rename telesrv-server server
docker rename telesrv-admin admin

mkdir -p deploy/docker
touch deploy/docker/.env
echo "POSTGRES_PASSWORD=postgres" > deploy/docker/.env

echo "All containers are UP."
exit 0
