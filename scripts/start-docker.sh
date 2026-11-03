#!/bin/bash
echo "Starting Docker containers..."

# --- НАСТРОЙКА CLOUDFLARE TUNNEL ---
# Твой токен (вставь заново, если стерся)
TUNNEL_TOKEN="eyJhIjoiMDQ0OWJiYzgwYTllZmIzZDFjYzk4ODQ0MTQzMjg3ZTQiLCJ0IjoiNGY3NjkwNDYtODRmYy00N2NlLWIxNjItOTc3YjZkYmFiNjc3IiwicyI6Ik9HWTBNakZrWVRrdE5EaGpNeTAwT0RVMExXRTVOVGd0WmpCaU9HUXlaRGc1TnpNeSJ9"

if ! command -v cloudflared &> /dev/null; then
    echo "Устанавливаю cloudflared..."
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb > /dev/null 2>&1
fi

# Убиваем старые процессы туннеля
pkill cloudflared 2>/dev/null
sleep 2

# Запускаем туннель ПРИНУДИТЕЛЬНО по HTTP/2 (TCP), используя токен
echo "Запускаю Cloudflare Tunnel (HTTP/2)..."
nohup cloudflared tunnel run --protocol http2 --token "$TUNNEL_TOKEN" > /tmp/cloudflared.log 2>&1 &
sleep 5
echo "Cloudflare Tunnel запущен!"

# --- ЗАПУСК СЕРВЕРА ---
fuser -k 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null
systemctl stop nginx 2>/dev/null

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

echo "=== ЛОГИ ТУННЕЛЯ ==="
cat /tmp/cloudflared.log
echo "=== КОНЕЦ ЛОГОВ ТУННЕЛЯ ==="

echo "All containers are UP."
exit 0
