#!/bin/bash
echo "Starting Docker containers..."

# Устанавливаем postgresql (клиент и сервер), чтобы CemixBuild нашел базу
apt-get update -qq
apt-get install -y -qq postgresql > /dev/null 2>&1

# Настраиваем пароль для локальной базы
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" > /dev/null 2>&1
sudo -u postgres psql -c "CREATE DATABASE telesrv;" > /dev/null 2>&1

# Запускаем Docker
docker compose -p telesrv -f docker-compose.yml up -d

sleep 10

echo "All containers are UP."
exit 0
