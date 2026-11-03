#!/bin/bash
echo "Starting Docker containers..."

# --- НАСТРОЙКА CLOUDFLARE TUNNEL ---
# ВСТАВЬ СЮДА СВОЙ ТОКЕН (длинную строку, которая начинается с eyJ...)
TUNNEL_TOKEN="eyJhIjoiMDQ0OWJiYzgwYTllZmIzZDFjYzk4ODQ0MTQzMjg3ZTQiLCJ0IjoiNGY3NjkwNDYtODRmYy00N2NlLWIxNjItOTc3YjZkYmFiNjc3IiwicyI6Ik9HWTBNakZrWVRrdE5EaGpNeTAwT0RVMExXRTVOVGd0WmpCaU9HUXlaRGc1TnpNeSJ9"

# Скачиваем cloudflared (если его еще нет)
if ! command -v cloudflared &> /dev/null; then
    echo "Устанавливаю cloudflared..."
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb > /dev/null 2>&1
fi

# Убиваем старые процессы туннеля и запускаем новый
pkill cloudflared 2>/dev/null
echo "Запускаю Cloudflare Tunnel..."
nohup cloudflared tunnel run --token "$TUNNEL_TOKEN" > /tmp/cloudflared.log 2>&1 &
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

echo "All containers are UP."
exit 0
