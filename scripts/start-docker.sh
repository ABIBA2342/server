#!/bin/bash
echo "Starting Docker containers..."

# Очищаем порты
fuser -k 2398/tcp 5432/tcp 2>/dev/null
systemctl stop postgresql 2>/dev/null

# Создаем файлы для CemixBuild
mkdir -p deploy/docker
echo "POSTGRES_PASSWORD=telesrv" > deploy/docker/.env
cp docker-compose.yml deploy/docker/compose.yaml
echo "POSTGRES_PASSWORD=telesrv" > .env

# Запускаем сервер (не пересобираем образы, чтобы было быстрее)
docker compose -p telesrv -f docker-compose.yml up -d

sleep 10

echo "=== ВАШ RSA КЛЮЧ ==="
docker cp telesrv-server:/app/data/server_rsa.pem /tmp/server_rsa.pem 2>/dev/null
openssl rsa -in /tmp/server_rsa.pem -RSAPublicKey_out 2>/dev/null || echo "Ключ еще не готов"
echo "=== КОНЕЦ ==="

# ВОТ ГЛАВНОЕ: ВЫТАСКИВАЕМ ЛОГИ С ОШИБКОЙ
echo "=== ЛОГИ СЕРВЕРА (ПОСЛЕДНИЕ 50 СТРОК) ==="
docker logs telesrv-server --tail 50
echo "=== КОНЕЦ ЛОГОВ ==="

echo "All containers are UP."
exit 0
