#!/bin/bash
echo "Starting Docker containers..."

# Убиваем порт 5432 (чтобы база не конфликтовала)
fuser -k 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null

# Устанавливаем Nginx (если его нет)
apt-get update -qq > /dev/null 2>&1
apt-get install -y nginx -qq > /dev/null 2>&1

# Настраиваем Nginx как прокси на порт 2398
cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 443 ssl;
    server_name 31.77.159.85;

    # Самоподписанный сертификат (нужен для работы WSS)
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    location / {
        proxy_pass http://127.0.0.1:2398;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Генерируем сертификат, если его нет
mkdir -p /etc/nginx/ssl
if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt \
        -subj "/C=RU/ST=Moscow/L=Moscow/O=SummerGram/CN=31.77.159.85" > /dev/null 2>&1
fi

# Перезапускаем Nginx
systemctl restart nginx

# Запускаем Docker
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

echo "=== ЛОГИ БОТА ==="
docker logs auth-bot 2>&1
echo "=== КОНЕЦ ЛОГОВ ==="

echo "All containers are UP."
exit 0
