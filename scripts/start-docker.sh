#!/bin/bash
echo "Starting Docker containers..."

# Создаем файл .env в корне (для Docker)
echo "POSTGRES_PASSWORD=telesrv" > .env

# Создаем файлы, которые ищет CemixBuild
mkdir -p deploy/docker
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env

# Запускаем
docker compose -p telesrv -f docker-compose.yml up -d

sleep 10

echo "All containers are UP."
exit 0
