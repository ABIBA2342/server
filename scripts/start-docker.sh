#!/bin/bash
echo "Starting Docker containers..."

# 1. Намертво убиваем всё, что занимает порт 5432 (база данных)
fuser -k 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null
systemctl disable postgresql 2>/dev/null

# 2. Создаем файлы для CemixBuild
mkdir -p deploy/docker
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > .env

# 3. Запускаем Docker
docker compose -p telesrv -f docker-compose.yml up -d

# 4. Ждем
sleep 15

echo "All containers are UP."
exit 0
