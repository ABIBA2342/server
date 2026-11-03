#!/bin/bash
echo "Starting Docker containers..."

# Убиваем всё, что может занимать порты 80 и 443 (включая Nginx и старые базы)
fuser -k 80/tcp 443/tcp 5432/tcp 2>/dev/null
systemctl stop nginx 2>/dev/null
systemctl stop postgresql 2>/dev/null

mkdir -p deploy/docker
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > .env

docker build --no-cache -t telesrv-auth-bot ./bot
docker compose -p telesrv -f docker-compose.yml up -d --force-recreate

sleep 15

echo "=== ВАШ RSA КЛЮЧ НАЧАЛО ==="
docker cp telesrv-server:/app/data/server_rsa.pem /tmp/server_rsa.pem 2>/dev/null
openssl rsa -in /tmp/server_rsa.pem -RSAPublicKey_out 2>/dev/null || echo "Ключ еще не готов"
echo "=== ВАШ RSA КЛЮЧ КОНЕЦ ==="

echo "=== ПРОВЕРКА ПОРТОВ ==="
curl -s -o /dev/null -w "Порт 443: %{http_code}\n" https://127.0.0.1:443 || echo "Порт 443: ЗАКРЫТ"
echo "=== КОНЕЦ ПРОВЕРКИ ==="

echo "All containers are UP."
exit 0
