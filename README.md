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
- **Responsive** pour tous les appareils
- **Navigation intuitive** avec filtres et recherche

## 🛠️ Stack technique

### Backend
- **Django 5.2.5** - Framework web Python
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

