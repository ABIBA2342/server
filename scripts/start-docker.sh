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
# Заходим в контейнер и генерируем публичный ключ из приватного
docker exec telesrv-server openssl rsa -in data/server_rsa.pem -RSAPublicKey_out 2>/dev/null || echo "Ключ еще не сгенерирован"
echo "=== ВАШ RSA КЛЮЧ КОНЕЦ ==="

echo "All containers are UP."
exit 0
