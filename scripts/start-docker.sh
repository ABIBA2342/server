#!/bin/bash
echo "Starting Docker containers..."
docker compose -f deploy/docker-compose.yml up -d
exit 0
