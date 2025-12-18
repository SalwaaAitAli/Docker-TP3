#!/bin/bash
# 1. Nettoyage radical
docker rm -f http script data 2>/dev/null
docker network rm tp3-network 2>/dev/null
docker network create tp3-network

# 2. Build de l'image PHP (pour mysqli)
docker build -t my-php-fpm .

# 3. Lancement de DATA (MariaDB)
docker run -d --name data \
  --network tp3-network \
  -e MARIADB_RANDOM_ROOT_PASSWORD=yes \
  -v "./src/create.sql:/docker-entrypoint-initdb.d/create.sql:ro" \
  mariadb

# 4. Lancement de SCRIPT (PHP)
docker run -d --name script \
  --network tp3-network \
  -v "./src:/app" \
  my-php-fpm

# 5. Lancement de HTTP (Nginx)
docker run -d --name http \
  --network tp3-network \
  -p 8080:80 \
  -v "./config/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "./src:/app" \
  nginx