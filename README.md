# 🎯 Palmarès Imara - Application de Gestion Scolaire

Application web moderne de **gestion de palmarès scolaire** développée avec Django.

## 🌐 Domaine de Production
**URL :** https://palmares.aedbimarasfs.org/

L'application sera déployée et accessible à cette adresse une fois la configuration terminée.

## 📋 Vue d'ensemble

L'école dispose de fichiers **Excel** contenant les colonnes suivantes :
- **Nom complet** - Nom et prénom de l'élève
- **Pourcentage** - Pourcentage obtenu
- **Classe** - Classe de l'élève
- **Section** - Section de l'élève
- **Année scolaire** - Année scolaire (ex: 2023-2024)

## 👥 Acteurs

### Administrateurs
- ✅ Import des fichiers Excel via Django Admin
- ✅ Gestion complète des données (CRUD)
- ✅ Accès aux fonctionnalités avancées

### Utilisateurs
- ✅ Consultation des résultats
- ✅ Recherche multi-critères
- ✅ Export PDF des résultats filtrés

## ⚙️ Fonctionnalités principales

### ✅ Import des données
- Upload de fichiers Excel (.xlsx) via interface admin
- Validation automatique des données
- Gestion des erreurs avec messages détaillés

### ✅ Consultation des données
- Affichage paginé des résultats (25 par page)
- Interface responsive avec Tailwind CSS
- Tri et organisation des données

### ✅ Recherche avancée
- Recherche multi-colonnes (nom, classe, section, année)
- Filtres dynamiques par classe, section et année
- Recherche en temps réel

### ✅ Export PDF
- Génération de rapports PDF formatés
- Export des résultats filtrés
- Tableaux structurés et lisibles

### ✅ Authentification
- Système d'authentification Django
- Superutilisateurs pour l'administration
- Utilisateurs standards pour consultation

## 🖥️ Interface utilisateur

- **Design moderne** avec Tailwind CSS
- **Interface entièrement en français**
- **Responsive** pour tous les appareils
- **Navigation intuitive** avec filtres et recherche

## 🛠️ Stack technique

### Backend
- **Django 5.2.5** - Framework web Python
- **SQLite** (développement)
- **PostgreSQL** (production)

### Frontend
- **Django Templates** - Moteur de templates
- **Tailwind CSS** - Framework CSS
- **JavaScript vanilla** - Interactions

### Déploiement
- **Docker** - Conteneurisation
- **Docker Compose** - Orchestration
- **Nginx** - Serveur web
- **Gunicorn** - Serveur WSGI

## 🚀 Installation et déploiement

### Développement local

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd palmares
   ```

2. **Configuration de l'environnement**
   ```bash
   python -m venv venv
   venv\Scripts\activate  # Windows
   # source venv/bin/activate  # Linux/Mac
   pip install -r requirements.txt
   ```

   > **Note pour Windows :** Si vous rencontrez une erreur avec `psycopg2-binary`, c'est normal. Ce package est uniquement nécessaire pour PostgreSQL en production. Pour le développement local, SQLite est utilisé par défaut.

3. **Configuration de la base de données**
   ```bash
   python manage.py migrate
   python manage.py createsuperuser
   ```

4. **Lancement du serveur**
   ```bash
   python manage.py runserver
   ```

5. **Accès à l'application**
   - Interface utilisateur : http://localhost:8000
   - Administration : http://localhost:8000/admin (utilisateur: admin, mot de passe: admin123)

### Déploiement en production

1. **Préparation du serveur**
   ```bash
   # Copier les fichiers sur votre VPS
   scp -r . user@vps:/var/www/palmares/
   ```

2. **Configuration**
   ```bash
   cd /var/www/palmares
   cp .env.example .env.prod
   # Éditer .env.prod avec vos valeurs
   ```

3. **Déploiement automatisé**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## 📁 Structure du projet

```
palmares/
├── palmares/                 # Configuration Django
│   ├── settings.py          # Paramètres principaux
│   ├── urls.py             # Routes principales
│   └── wsgi.py             # Point d'entrée WSGI
├── palmares_app/            # Application principale
│   ├── models.py           # Modèles de données
│   ├── views.py            # Vues et logique
│   ├── admin.py            # Configuration admin
│   ├── urls.py             # Routes de l'app
│   └── templates/          # Templates HTML
├── Dockerfile               # Configuration Docker
├── docker-compose.yml       # Développement
├── docker-compose.prod.yml  # Production
├── nginx.conf              # Configuration Nginx
├── requirements.txt         # Dépendances Python
├── deploy.sh               # Script de déploiement
└── .env.example           # Exemple de configuration
```

## 🔧 Configuration

### Variables d'environnement (.env)

**Pour le développement :**
```bash
# Copier le fichier d'exemple
cp .env.example .env

# Le fichier .env est déjà configuré pour le développement
# avec DEBUG=True et SQLite
```

**Pour la production :**
```bash
# Créer le fichier de production
cp .env.example .env.prod

# Éditer avec vos valeurs de production
nano .env.prod
```

**Variables importantes :**
```bash
# Sécurité
DEBUG=False                                      # Toujours False en production
SECRET_KEY=votre-cle-secrete-unique              # Générer une nouvelle clé
ALLOWED_HOSTS=palmares.aedbimarasfs.org         # Domaine configuré

# Configuration spécifique pour palmares.aedbimarasfs.org
DB_NAME=palmares_imara_prod
DB_USER=palmares_user
DB_PASSWORD=votre-mot-de-passe-complexe
```

# Base de données PostgreSQL
DB_ENGINE=postgresql
DB_NAME=palmares_imara_db
DB_USER=palmares_user
DB_PASSWORD=mot-de-passe-complexe
DB_HOST=localhost
DB_PORT=5432

# Fichiers statiques
STATIC_URL=/static/
STATIC_ROOT=staticfiles
MEDIA_URL=/media/
MEDIA_ROOT=media
```

### Format des fichiers Excel

Les fichiers Excel doivent contenir les colonnes suivantes (première ligne = en-têtes) :
1. **Nom complet** - Texte
2. **Pourcentage** - Nombre décimal
3. **Classe** - Texte
4. **Section** - Texte
5. **Année scolaire** - Texte (format: 2023-2024)

## 📊 Utilisation

### Pour les administrateurs

1. **Connexion** : Accéder à `/admin/` avec les identifiants superutilisateur
2. **Import Excel** : Utiliser le bouton "Importer depuis Excel" dans la liste des résultats
3. **Gestion** : Ajouter, modifier ou supprimer des enregistrements via l'interface admin

### Pour les utilisateurs

1. **Consultation** : Page d'accueil avec tous les résultats
2. **Recherche** : Utiliser les filtres et la barre de recherche
3. **Export** : Bouton "Exporter PDF" pour télécharger les résultats

## 🔒 Sécurité

- Authentification obligatoire pour l'administration
- Validation des données d'entrée
- Protection CSRF activée
- Headers de sécurité configurés
- Conteneurisation sécurisée

## 📈 Performance

- Pagination côté serveur
- Optimisation des requêtes
- Cache des fichiers statiques
- Compression Gzip
- Base de données indexée

## 🐛 Dépannage

### Problèmes courants

1. **Erreur psycopg2-binary sur Windows**
   ```bash
   # Cette erreur est normale en développement
   # psycopg2-binary nécessite Microsoft Visual C++ Build Tools
   # Pour le développement, utilisez SQLite (configuré par défaut)
   # Pour la production sur Linux, psycopg2 s'installera correctement
   ```

   **Solutions alternatives :**
   - Utiliser Docker pour le développement (recommandé)
   - Installer PostgreSQL localement et utiliser dj-database-url
   - Continuer avec SQLite pour le développement

2. **Erreur de migration**
   ```bash
   python manage.py migrate --fake-initial
   ```

3. **Problème de permissions**
   ```bash
   sudo chown -R www-data:www-data /var/www/palmares/
   ```

4. **Erreur Docker**
   ```bash
   docker-compose down
   docker-compose up --build
   ```

5. **Problème de locale française**
   ```bash
   # Assurez-vous que le système supporte UTF-8
   # Sur Windows, définissez la variable d'environnement:
   set PYTHONUTF8=1
   ```

## 📝 Notes de développement

- Interface entièrement en français
- Code PEP 8 compliant
- Tests unitaires recommandés
- Documentation des fonctions
- Gestion d'erreurs robuste

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature
3. Commiter les changements
4. Push vers la branche
5. Créer une Pull Request

## 🚀 Guide de Déploiement Complet sur Ubuntu

### 📋 Configurations Nginx - Quelle utiliser ?

**⚠️ IMPORTANT : Deux configurations Nginx distinctes**

1. **`nginx.docker.conf`** - Configuration Docker (utilisée par Docker Compose)
   - Emplacement : Racine du projet
   - Utilisation : `docker-compose -f docker-compose.prod.yml up`
   - Contexte : Conteneurisation avec Docker

2. **Configuration Ubuntu** - Configuration serveur (utilisée sur votre VPS)
   - Emplacement : `/etc/nginx/sites-available/palmares_imara`
   - Utilisation : Serveur Ubuntu natif
   - Contexte : Déploiement en production sur VPS

**🎯 Quand utiliser quoi ?**
- **Docker** : Utilisez `nginx.docker.conf` avec Docker Compose
- **VPS Ubuntu** : Utilisez la configuration du guide ci-dessous
- **Ne mélangez pas** : Ces deux fichiers ont des objectifs différents !

### Prérequis système

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation des dépendances système
sudo apt install -y curl wget git ufw python3 python3-pip

# Installation de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installation de Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Redémarrage de la session pour appliquer les changements Docker
newgrp docker
```

### 1. Préparation du serveur Ubuntu

```bash
# Création des répertoires nécessaires
sudo mkdir -p /var/www/palmares_imara
sudo chown $USER:$USER /var/www/palmares_imara

# Configuration du firewall
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Vérification du firewall
sudo ufw status
```

### 2. Déploiement de l'application

```bash
# Aller dans le répertoire de l'application
cd /var/www/palmares_imara

# Copier ou cloner les fichiers du projet
# (Remplacez cette étape selon votre méthode de déploiement)
# Exemple avec Git :
# git clone https://github.com/votre-repo/palmares-imara.git .

# Configuration des variables d'environnement
cp .env.example .env.prod

# Éditer le fichier .env.prod avec vos valeurs
nano .env.prod
```

**Contenu du fichier `.env.prod` :**
```bash
# Configuration Django
DEBUG=0
SECRET_KEY=votre-cle-secrete-très-longue-et-complexe-ici
ALLOWED_HOSTS=votre-domaine.com,localhost,127.0.0.1

# Configuration de la base de données PostgreSQL
DB_NAME=palmares_imara_db
DB_USER=palmares_user
DB_PASSWORD=votre-mot-de-passe-complexe
DB_HOST=db
DB_PORT=5432
```

### 3. Configuration et lancement avec Docker

```bash
# Construction des images Docker
docker-compose -f docker-compose.prod.yml build

# Démarrage des services
docker-compose -f docker-compose.prod.yml up -d

# Vérification que les services sont démarrés
docker-compose -f docker-compose.prod.yml ps

# Application des migrations de base de données
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate

# Collecte des fichiers statiques
docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --noinput
```

### 4. Installation et configuration de Nginx

```bash
# Installation de Nginx
sudo apt install -y nginx

# ⚠️ IMPORTANT : Utilisez la configuration ci-dessous pour le serveur Ubuntu
# NE PAS confondre avec nginx.docker.conf (utilisé par Docker)

# Création de la configuration pour Palmarès Imara
sudo tee /etc/nginx/sites-available/palmares_imara > /dev/null <<EOF
server {
    listen 80;
    server_name votre-domaine.com www.votre-domaine.com;

    # Logs
    access_log /var/log/nginx/palmares_imara_access.log;
    error_log /var/log/nginx/palmares_imara_error.log;

    # Sécurité
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Proxy vers l'application Django
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # Timeouts
        proxy_connect_timeout 75s;
        proxy_send_timeout 75s;
        proxy_read_timeout 75s;
    }

    # Fichiers statiques
    location /static/ {
        alias /var/www/palmares_imara/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Fichiers médias
    location /media/ {
        alias /var/www/palmares_imara/media/;
        expires 1M;
        add_header Cache-Control "public";
    }
}
EOF

# Activation du site
sudo ln -sf /etc/nginx/sites-available/palmares_imara /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test de la configuration Nginx
sudo nginx -t

# Redémarrage de Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 5. Configuration SSL avec Let's Encrypt (recommandé)

```bash
# Installation de Certbot
sudo apt install -y certbot python3-certbot-nginx

# Génération du certificat SSL
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com --email votre-email@domaine.com --agree-tos --non-interactive

# Vérification du renouvellement automatique
sudo certbot renew --dry-run
```

### 6. Création des utilisateurs

```bash
# Création d'un superutilisateur Django
docker-compose -f docker-compose.prod.yml exec web python manage.py createsuperuser

# Création d'utilisateurs réguliers via l'interface admin
# Accéder à : https://votre-domaine.com/admin/
```

### 7. Configuration des tâches planifiées (optionnel)

```bash
# Sauvegarde automatique de la base de données
echo "0 2 * * * cd /var/www/palmares_imara && docker-compose -f docker-compose.prod.yml exec -T db pg_dump -U palmares_user palmares_imara_db > /var/backups/palmares_backup_\$(date +\%Y\%m\%d).sql" | sudo crontab -

# Redémarrage automatique des services
echo "@reboot cd /var/www/palmares_imara && docker-compose -f docker-compose.prod.yml up -d" | sudo crontab -

# Nettoyage des anciens fichiers de logs
echo "0 3 * * * find /var/www/palmares_imara/media/import_errors/ -name '*.csv' -mtime +30 -delete" | sudo crontab -
```

## 📋 Utilisation de l'application

### Accès aux interfaces

- **Application principale** : `https://palmares.aedbimarasfs.org/`
- **Interface d'administration** : `https://palmares.aedbimarasfs.org/admin/`
- **Logs d'importation** : `https://palmares.aedbimarasfs.org/import-logs/`

### Comptes par défaut

- **Administrateur** : Créé lors du déploiement
- **Utilisateur de test** : `user` / `user123`

### Import de données

1. Se connecter en tant qu'administrateur
2. Aller dans l'interface admin : `/admin/`
3. Sélectionner "Résultats" > "Importer depuis Excel"
4. Sélectionner votre fichier Excel (.xlsx)
5. Consulter les logs en cas d'erreurs : `/import-logs/`

## 🔧 Maintenance et monitoring

### Mise à jour de l'application

```bash
# Arrêt des services
cd /var/www/palmares_imara
docker-compose -f docker-compose.prod.yml down

# Mise à jour du code
# (Votre méthode de déploiement - Git, SCP, etc.)

# Reconstruction et redémarrage
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

# Migration si nécessaire
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate
```

### Sauvegarde

```bash
# Sauvegarde de la base de données
docker-compose -f docker-compose.prod.yml exec db pg_dump -U palmares_user palmares_imara_db > palmares_backup_$(date +%Y%m%d).sql

# Sauvegarde des fichiers médias
tar -czf media_backup_$(date +%Y%m%d).tar.gz media/
```

### Monitoring

```bash
# Vérification des logs de l'application
docker-compose -f docker-compose.prod.yml logs -f web

# Vérification des logs Nginx
sudo tail -f /var/log/nginx/palmares_imara_access.log
sudo tail -f /var/log/nginx/palmares_imara_error.log

# Vérification de l'état des services
docker-compose -f docker-compose.prod.yml ps

# Monitoring des ressources
docker stats
```

## 🐛 Dépannage

### Problèmes courants et solutions

**1. Erreur 502 Bad Gateway :**
```bash
# Vérifier l'état de Gunicorn
docker-compose -f docker-compose.prod.yml exec web ps aux | grep gunicorn

# Redémarrer les services
docker-compose -f docker-compose.prod.yml restart
```

**2. Erreur de connexion à la base de données :**
```bash
# Vérifier les variables d'environnement
docker-compose -f docker-compose.prod.yml exec web env | grep DB

# Vérifier l'état de PostgreSQL
docker-compose -f docker-compose.prod.yml exec db pg_isready -U palmares_user -d palmares_imara_db
```

**3. Problème de permissions :**
```bash
# Corriger les permissions des fichiers
sudo chown -R www-data:www-data /var/www/palmares_imara/staticfiles/
sudo chown -R www-data:www-data /var/www/palmares_imara/media/

# Redémarrer Nginx
sudo systemctl restart nginx
```

**4. Erreur SSL Let's Encrypt :**
```bash
# Vérifier la configuration DNS
nslookup votre-domaine.com

# Tester la connectivité
curl -I http://votre-domaine.com
```

**5. Problème de mémoire Docker :**
```bash
# Nettoyer les images et conteneurs inutilisés
docker system prune -a

# Redémarrer Docker
sudo systemctl restart docker
```

## 📊 Métriques et performances

### Optimisations appliquées

- **Pagination côté serveur** : Gestion efficace des gros volumes
- **Index de base de données** : Requêtes optimisées
- **Cache des fichiers statiques** : Expiration 1 an
- **Compression Gzip** : Réduction de la bande passante
- **Conteneurisation** : Isolation et scalabilité

### Monitoring recommandé

- **Logs d'accès** : Analyse du trafic
- **Logs d'erreurs** : Détection des problèmes
- **Métriques système** : CPU, mémoire, disque
- **Sauvegardes automatiques** : Sécurité des données

## 🔒 Sécurité

### Mesures de sécurité implémentées

- **Authentification obligatoire** : Accès protégé
- **HTTPS forcé** : Chiffrement des communications
- **Headers de sécurité** : Protection XSS, CSRF
- **Validation des entrées** : Protection contre les injections
- **Conteneurs isolés** : Sécurité renforcée

### Recommandations supplémentaires

```bash
# Configuration de fail2ban pour la protection SSH
sudo apt install -y fail2ban
sudo systemctl enable fail2ban

# Mise à jour régulière du système
sudo apt update && sudo apt upgrade -y

# Monitoring des logs de sécurité
sudo tail -f /var/log/auth.log
```

## 🔒 Sécurité - Fichiers .gitignore

Le fichier `.gitignore` inclus protège vos informations sensibles :

### ✅ Fichiers ignorés automatiquement :
- **Variables d'environnement** : `.env`, `.env.prod`
- **Base de données** : `*.sqlite3`, PostgreSQL dumps
- **Fichiers temporaires** : `__pycache__/`, `*.pyc`
- **Logs sensibles** : Fichiers de logs d'importation
- **Certificats SSL** : `*.pem`, `*.key`, `*.crt`
- **Données médias** : Contenu du dossier `media/`

### ✅ Fichiers à commiter :
- **Configuration** : `Dockerfile`, `docker-compose.yml`
- **Code source** : Tous les fichiers `.py`, templates
- **Documentation** : `README.md`, exemples
- **Structure** : `requirements.txt`, `.env.example`

### 🔧 Utilisation du .gitignore :

```bash
# Initialiser Git
git init

# Ajouter tous les fichiers (sauf ceux ignorés)
git add .

# Premier commit
git commit -m "Initial commit - Palmarès Imara"

# Vérifier les fichiers ignorés
git status --ignored
```

## 📞 Support

Pour toute question ou problème :

1. **Consulter les logs** : Application, Nginx, Docker
2. **Vérifier l'état des services** : `docker-compose ps`
3. **Tester la connectivité** : `curl -I https://votre-domaine.com`
4. **Vérifier les permissions** : Droits d'accès aux fichiers

### Commandes de diagnostic utiles

```bash
# État des services
sudo systemctl status nginx
sudo systemctl status docker

# Logs détaillés
docker-compose -f docker-compose.prod.yml logs -f
sudo journalctl -u nginx -f

# Test de l'application
curl -k https://palmares.aedbimarasfs.org/
curl -k https://palmares.aedbimarasfs.org/admin/
```

---

**Palmarès Imara** - Gestion moderne et sécurisée des résultats scolaires © 2025 🎓✨
