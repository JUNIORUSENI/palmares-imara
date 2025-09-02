#!/bin/bash

# Script de déploiement pour l'application Palmarès Scolaire
# À exécuter sur votre serveur VPS

set -e

echo "🚀 Début du déploiement de l'application Palmarès Scolaire"

# Variables (à adapter selon votre configuration)
PROJECT_NAME="palmares"
DOMAIN="votre-domaine.com"
EMAIL="admin@votre-domaine.com"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction d'affichage des messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi

    log_info "Prérequis vérifiés avec succès"
}

# Configuration du firewall
setup_firewall() {
    log_info "Configuration du firewall..."

    # UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        sudo ufw allow ssh
        sudo ufw allow 'Nginx Full'
        sudo ufw --force enable
        log_info "Firewall UFW configuré"
    fi

    # Firewalld (CentOS/RHEL)
    if command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --reload
        log_info "Firewall Firewalld configuré"
    fi
}

# Installation de Nginx (si pas déjà installé)
install_nginx() {
    if ! command -v nginx &> /dev/null; then
        log_info "Installation de Nginx..."
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y nginx
        elif command -v yum &> /dev/null; then
            sudo yum install -y nginx
        fi
        sudo systemctl enable nginx
        log_info "Nginx installé"
    else
        log_info "Nginx déjà installé"
    fi
}

# Configuration SSL avec Let's Encrypt (optionnel)
setup_ssl() {
    if command -v certbot &> /dev/null; then
        log_info "Configuration SSL avec Let's Encrypt..."
        sudo certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --non-interactive
        log_info "SSL configuré"
    else
        log_warn "Certbot n'est pas installé. SSL non configuré."
        log_warn "Pour configurer SSL plus tard: sudo apt install certbot python3-certbot-nginx"
    fi
}

# Déploiement de l'application
deploy_application() {
    log_info "Déploiement de l'application..."

    # Création des répertoires nécessaires
    sudo mkdir -p /var/www/$PROJECT_NAME
    sudo chown $USER:$USER /var/www/$PROJECT_NAME

    # Copie des fichiers (à adapter selon votre méthode de déploiement)
    # Ici, on suppose que les fichiers sont déjà sur le serveur
    # Vous pouvez utiliser Git, SCP, ou autre méthode

    cd /var/www/$PROJECT_NAME

    # Création du fichier .env.prod
    if [ ! -f .env.prod ]; then
        log_info "Création du fichier .env.prod..."
        cat > .env.prod << EOF
DEBUG=0
SECRET_KEY=$(openssl rand -hex 32)
ALLOWED_HOSTS=$DOMAIN,localhost,127.0.0.1
DB_NAME=palmares_db
DB_USER=palmares_user
DB_PASSWORD=$(openssl rand -hex 16)
DB_HOST=db
DB_PORT=5432
EOF
        log_warn "Fichier .env.prod créé. Veuillez vérifier et ajuster les valeurs sensibles."
    fi

    # Construction et démarrage des conteneurs
    log_info "Construction des conteneurs Docker..."
    docker-compose -f docker-compose.prod.yml build

    log_info "Démarrage des services..."
    docker-compose -f docker-compose.prod.yml up -d

    # Collecte des fichiers statiques
    log_info "Collecte des fichiers statiques..."
    docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --noinput

    # Application des migrations
    log_info "Application des migrations de base de données..."
    docker-compose -f docker-compose.prod.yml exec web python manage.py migrate

    # Création du superutilisateur (optionnel)
    log_info "Création du superutilisateur Django..."
    docker-compose -f docker-compose.prod.yml exec web python manage.py createsuperuser --noinput --username admin --email $EMAIL 2>/dev/null || log_warn "Superutilisateur non créé automatiquement. À faire manuellement."

    log_info "Application déployée avec succès"
}

# Configuration de Nginx
configure_nginx() {
    log_info "Configuration de Nginx..."

    # Sauvegarde de la configuration par défaut
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

    # Création de la configuration pour l'application
    sudo tee /etc/nginx/sites-available/$PROJECT_NAME > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static/ {
        alias /var/www/$PROJECT_NAME/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /media/ {
        alias /var/www/$PROJECT_NAME/media/;
        expires 1M;
        add_header Cache-Control "public";
    }
}
EOF

    # Activation du site
    sudo ln -sf /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default

    # Test de la configuration
    sudo nginx -t

    # Redémarrage de Nginx
    sudo systemctl restart nginx

    log_info "Nginx configuré"
}

# Fonction principale
main() {
    log_info "Script de déploiement de l'application Palmarès Scolaire"
    log_info "Domaine: $DOMAIN"
    log_info "Email: $EMAIL"

    check_prerequisites
    setup_firewall
    install_nginx
    deploy_application
    configure_nginx
    setup_ssl

    log_info "🎉 Déploiement terminé avec succès!"
    log_info "Votre application est accessible sur: http://$DOMAIN"
    log_info "Interface d'administration: http://$DOMAIN/admin/"
    log_info ""
    log_warn "N'oubliez pas de:"
    log_warn "1. Changer le mot de passe du superutilisateur Django"
    log_warn "2. Configurer un certificat SSL pour HTTPS"
    log_warn "3. Configurer les sauvegardes automatiques"
    log_warn "4. Monitorer les logs et les performances"
}

# Exécution
main "$@"