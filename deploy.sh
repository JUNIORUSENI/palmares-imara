#!/bin/bash

#===============================================================================
# 🚀 SCRIPT DE DÉPLOIEMENT - APPLICATION PALMARÈS IMARA
#===============================================================================
#
# 📋 DESCRIPTION:
#     Script automatisé pour déployer l'application Palmarès Imara
#     sur un serveur Ubuntu avec Docker et Docker Compose
#
# 🎯 FONCTIONNALITÉS:
#     ✅ Vérification des prérequis (Docker, Docker Compose)
#     ✅ Configuration du firewall (UFW)
#     ✅ Installation et configuration de Nginx
#     ✅ Déploiement des conteneurs Docker
#     ✅ Configuration SSL avec Let's Encrypt (optionnel)
#     ✅ Tests de fonctionnement post-déploiement
#
# 📍 DOMAINE: https://palmares.aedbimarasfs.org/
#
# 🛠️  UTILISATION:
#     chmod +x deploy.sh
#     ./deploy.sh
#
# ⚠️  PRÉREQUIS:
#     - Ubuntu 20.04+ ou Debian 11+
#     - Accès root ou sudo
#     - Domaine configuré (DNS pointant vers le serveur)
#
#===============================================================================

set -e

echo "🚀 Début du déploiement de l'application Palmarès Scolaire"

# Variables (à adapter selon votre configuration)
PROJECT_NAME="palmares"
DOMAIN="palmares.aedbimarasfs.org"
EMAIL="admin@aedbimarasfs.org"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction d'affichage des messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Fonction d'aide
show_help() {
    echo "================================================================================"
    echo "🚀 SCRIPT DE DÉPLOIEMENT - APPLICATION PALMARÈS IMARA"
    echo "================================================================================"
    echo ""
    echo "📋 DESCRIPTION:"
    echo "    Script automatisé pour déployer l'application Palmarès Imara"
    echo "    sur un serveur Ubuntu avec Docker et Docker Compose"
    echo ""
    echo "🎯 UTILISATION:"
    echo "    ./deploy.sh              # Déploiement complet"
    echo "    ./deploy.sh --help       # Afficher cette aide"
    echo "    ./deploy.sh --version    # Afficher la version"
    echo ""
    echo "📍 CONFIGURATION ACTUELLE:"
    echo "    Domaine: $DOMAIN"
    echo "    Email: $EMAIL"
    echo "    Projet: $PROJECT_NAME"
    echo ""
    echo "⚠️  PRÉREQUIS SYSTÈME:"
    echo "    • Ubuntu 20.04+ ou Debian 11+"
    echo "    • Accès root ou sudo"
    echo "    • Domaine configuré (DNS pointant vers le serveur)"
    echo "    • Ports 80 et 443 ouverts"
    echo ""
    echo "🛠️  ÉTAPES DU DÉPLOIEMENT:"
    echo "    1. ✅ Vérification des prérequis"
    echo "    2. 🌐 Vérification du domaine"
    echo "    3. 🔒 Configuration du firewall"
    echo "    4. 🌐 Installation de Nginx"
    echo "    5. 🐳 Déploiement Docker"
    echo "    6. ⚙️  Configuration Nginx"
    echo "    7. 🔒 Configuration SSL (optionnel)"
    echo "    8. ✅ Tests post-déploiement"
    echo ""
    echo "📁 FICHIERS CRÉÉS:"
    echo "    • .env.prod (variables d'environnement)"
    echo "    • /etc/nginx/sites-available/$PROJECT_NAME"
    echo "    • Conteneurs Docker (PostgreSQL, Django, Nginx)"
    echo ""
    echo "🌐 URLS APRÈS DÉPLOIEMENT:"
    echo "    • Application: http://$DOMAIN"
    echo "    • Admin: http://$DOMAIN/admin/"
    echo "    • Status: http://$DOMAIN/health/"
    echo ""
    echo "================================================================================"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."

    # Vérification de Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé. Veuillez l'installer d'abord."
        log_info "Commande d'installation: sudo apt install docker.io"
        exit 1
    fi

    # Vérification de Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé. Veuillez l'installer d'abord."
        log_info "Commande d'installation: sudo apt install docker-compose"
        exit 1
    fi

    # Vérification des permissions Docker
    if ! docker info &> /dev/null; then
        log_error "Docker n'est pas accessible. Ajoutez votre utilisateur au groupe docker:"
        log_info "Commande: sudo usermod -aG docker $USER"
        log_info "Puis redémarrez votre session ou exécutez: newgrp docker"
        exit 1
    fi

    log_success "Prérequis vérifiés avec succès"
}

# Vérification de la configuration du domaine
check_domain() {
    log_info "Vérification de la configuration du domaine $DOMAIN..."

    # Test de résolution DNS
    if ! nslookup $DOMAIN &> /dev/null; then
        log_warn "Le domaine $DOMAIN ne résout pas. Vérifiez la configuration DNS."
    else
        log_success "Le domaine $DOMAIN résout correctement"
    fi

    # Test de connectivité
    if curl -s --head --max-time 10 https://$DOMAIN | head -n 1 | grep -q "200\|301\|302"; then
        log_warn "Le domaine $DOMAIN semble déjà configuré. Vérifiez les conflits potentiels."
    else
        log_info "Le domaine $DOMAIN est disponible pour la configuration"
    fi
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

    # Vérification de l'état des services
    log_info "Vérification de l'état des services..."
    sleep 10

    # Vérifier que les conteneurs sont en cours d'exécution
    if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        log_success "Les conteneurs Docker sont opérationnels"
    else
        log_error "Problème avec les conteneurs Docker"
        docker-compose -f docker-compose.prod.yml logs
        exit 1
    fi

    # Test de l'application
    if curl -s --head --max-time 30 http://localhost:8000 | head -n 1 | grep -q "200\|301\|302"; then
        log_success "L'application Django répond correctement"
    else
        log_error "L'application Django ne répond pas"
        docker-compose -f docker-compose.prod.yml logs web
        exit 1
    fi

    log_success "Application déployée avec succès"
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
    # Gestion des arguments
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --version|-v)
            echo "Palmarès Imara - Script de déploiement v1.0"
            echo "Domaine: $DOMAIN"
            exit 0
            ;;
        "")
            # Pas d'argument, procéder au déploiement
            ;;
        *)
            log_error "Argument inconnu: $1"
            log_info "Utilisez --help pour voir l'aide"
            exit 1
            ;;
    esac

    log_info "🚀 DÉBUT DU DÉPLOIEMENT - Application Palmarès Imara"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "📍 Domaine: $DOMAIN"
    log_info "📧 Email: $EMAIL"
    log_info "🏗️  Projet: $PROJECT_NAME"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Vérifications pré-déploiement
    check_prerequisites
    check_domain

    # Configuration système
    setup_firewall
    install_nginx

    # Déploiement de l'application
    deploy_application

    # Configuration web
    configure_nginx
    setup_ssl

    # Finalisation
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "🎉 DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    log_info "🌐 URLs d'accès :"
    log_info "   📱 Application: http://$DOMAIN"
    log_info "   🔧 Admin: http://$DOMAIN/admin/"
    log_info "   📊 Status: http://$DOMAIN/health/"

    log_info ""
    log_warn "📋 ACTIONS RECOMMANDÉES :"
    log_warn "   1. 🔐 Changer le mot de passe admin (admin/admin123)"
    log_warn "   2. 🔒 Configurer HTTPS avec Let's Encrypt"
    log_warn "   3. 💾 Configurer les sauvegardes PostgreSQL"
    log_warn "   4. 📊 Monitorer les logs et performances"
    log_warn "   5. 🔧 Tester l'import Excel et l'export PDF"

    log_info ""
    log_info "📁 Fichiers de configuration créés :"
    log_info "   ⚙️  .env.prod (variables d'environnement)"
    log_info "   🐳 docker-compose.prod.yml (services)"
    log_info "   🌐 /etc/nginx/sites-available/$PROJECT_NAME (Nginx)"

    log_info ""
    log_success "✨ L'application Palmarès Imara est maintenant opérationnelle !"
}

# Exécution
main "$@"