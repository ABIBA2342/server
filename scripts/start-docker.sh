#!/bin/bash
echo "Starting Docker containers..."

fuser -k 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null

mkdir -p deploy/docker
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > .env

# ЖЕСТКАЯ ПЕРЕСБОРКА БОТА БЕЗ КЭША
docker build --no-cache -t telesrv-auth-bot ./bot

# Запускаем всё остальное
docker compose -p telesrv -f docker-compose.yml up -d --force-recreate

sleep 15

echo "=== ВАШ RSA КЛЮЧ НАЧАЛО ==="
docker cp telesrv-server:/app/data/server_rsa.pem /tmp/server_rsa.pem 2>/dev/null
openssl rsa -in /tmp/server_rsa.pem -RSAPublicKey_out 2>/dev/null || echo "Ключ еще не готов"
echo "=== ВАШ RSA КЛЮЧ КОНЕЦ ==="

echo "=== ЛОГИ БОТА ==="
docker logs auth-bot 2>&1
echo "=== КОНЕЦ ЛОГОВ ==="

echo "All containers are UP."
exit 0
