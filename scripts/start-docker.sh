#!/bin/bash
echo "Starting Docker containers..."

fuser -k 2398/tcp 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null

mkdir -p deploy/docker
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > .env

docker compose -p telesrv -f docker-compose.yml up -d --force-recreate

sleep 15

echo "=== ВАШ RSA КЛЮЧ ==="
docker cp telesrv-server:/app/data/server_rsa.pem /tmp/server_rsa.pem 2>/dev/null
openssl rsa -in /tmp/server_rsa.pem -RSAPublicKey_out 2>/dev/null || echo "Ключ еще не готов"
echo "=== КОНЕЦ ==="

echo "=== ОЖИДАНИЕ ВХОДА (нажмите Join в клиенте СЕЙЧАС) ==="
# Ждем 60 секунд и показываем логи сервера в реальном времени
timeout 60 docker logs -f telesrv-server || true
echo "=== КОНЕЦ ОЖИДАНИЯ ==="

echo "All containers are UP."
exit 0
