#!/bin/bash
echo "Starting Docker containers..."

# Запускаем Cloudflare Tunnel
if ! command -v cloudflared &> /dev/null; then
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb > /dev/null 2>&1
fi

pkill cloudflared 2>/dev/null
sleep 2

nohup cloudflared tunnel --url tcp://localhost:2398 --protocol http2 > /tmp/cloudflared.log 2>&1 &
sleep 10

TUNNEL_URL=$(grep -o 'https://.*\.trycloudflare\.com' /tmp/cloudflared.log | head -1)
echo "========================================="
echo "ВАШ НОВЫЙ АДРЕС:"
echo "$TUNNEL_URL"
echo "========================================="

# Запускаем сервер
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

echo "All containers are UP."
exit 0
