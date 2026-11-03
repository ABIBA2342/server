#!/bin/bash
echo "Starting Docker containers..."

docker rm -f telesrv-postgres telesrv-redis telesrv-server telesrv-admin postgres redis server admin 2>/dev/null

docker compose -p postgres -f docker-compose.yml up -d

sleep 10

mkdir -p deploy/docker
touch deploy/docker/.env
echo "POSTGRES_PASSWORD=postgres" > deploy/docker/.env

echo "All containers are UP."
exit 0
