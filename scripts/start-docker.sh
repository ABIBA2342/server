#!/bin/bash
echo "Starting Docker containers..."

fuser -k 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null

mkdir -p deploy/docker
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > .env

docker compose -p telesrv -f docker-compose.yml up -d

sleep 15

echo "=== ВАШ RSA КЛЮЧ НАЧАЛО ==="
# 1. Копируем приватный ключ из контейнера на сервер
docker cp telesrv-server:/app/data/server_rsa.pem /tmp/server_rsa.pem
# 2. Генерируем публичный ключ на самом сервере (в Ubuntu)
openssl rsa -in /tmp/server_rsa.pem -RSAPublicKey_out
echo "=== ВАШ RSA КЛЮЧ КОНЕЦ ==="

echo "All containers are UP."
exit 0
