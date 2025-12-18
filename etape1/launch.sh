#!/bin/bash

# 1. Nettoyage des containers existants (Etape 0)
docker stop http script 2>/dev/null
docker rm http script 2>/dev/null

# 2. Création du réseau personnalisé
# On vérifie s'il existe déjà pour éviter l'erreur
docker network inspect tp3-network >/dev/null 2>&1 || \
    docker network create tp3-network

# 3. Lancement du container SCRIPT (PHP-FPM)
# On monte le dossier src dans /app
docker run -d \
    --name script \
    --network tp3-network \
    -v $(pwd)/src:/app \
    php:8.2-fpm

# 4. Lancement du container HTTP (Nginx)
# On monte le dossier src dans /app ET le fichier de config
docker run -d \
    --name http \
    --network tp3-network \
    -p 8080:80 \
    -v $(pwd)/src:/app \
    -v $(pwd)/config/default.conf:/etc/nginx/conf.d/default.conf:ro \
    nginx:latest

echo "L'étape 1 est déployée sur http://localhost:8080"