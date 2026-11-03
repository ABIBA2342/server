#!/bin/bash
echo "Starting Docker containers..."

# Убиваем порт базы данных, если занят
fuser -k 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null

# Удаляем старого бота, чтобы он пересобрался с новым токеном
docker rm -f auth-bot 2>/dev/null

# Создаем файлы для CemixBuild
mkdir -p deploy/docker
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > .env

# Запускаем контейнеры
docker compose -p telesrv -f docker-compose.yml up -d --build

sleep 15

echo "=== ВАШ RSA КЛЮЧ НАЧАЛО ==="
docker cp telesrv-server:/app/data/server_rsa.pem /tmp/server_rsa.pem 2>/dev/null
openssl rsa -in /tmp/server_rsa.pem -RSAPublicKey_out 2>/dev/null || echo "Ключ еще не готов"
echo "=== ВАШ RSA КЛЮЧ КОНЕЦ ==="

echo "=== ЛОГИ БОТА (ОШИБКИ, ЕСЛИ ЕСТЬ) ==="
docker logs auth-bot 2>&1
echo "=== КОНЕЦ ЛОГОВ БОТА ==="

echo "All containers are UP."
exit 0
