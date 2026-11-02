#!/bin/bash
echo "Starting Docker containers..."
docker compose -f docker-compose.yml up -d
exit 0
