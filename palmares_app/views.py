from django.shortcuts import render, get_object_or_404, redirect
from django.core.paginator import Paginator
from django.db.models import Q
from django.http import HttpResponse, Http404
from django.template.loader import get_template
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from .models import Resultat, Classe, Section, AnneeScolaire
import io
import os
import csv
from datetime import datetime
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
from reportlab.lib import colors


def login_view(request):
    """Vue de connexion pour les utilisateurs"""
    if request.user.is_authenticated:
        return redirect('palmares_app:home')

    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            messages.success(request, f"Bienvenue, {user.username} !")
            return redirect('palmares_app:home')
        else:
            messages.error(request, "Nom d'utilisateur ou mot de passe incorrect.")

    return render(request, 'palmares_app/login.html')


def logout_view(request):
    """Vue de déconnexion"""
    logout(request)
    messages.info(request, "Vous avez été déconnecté.")
    return redirect('palmares_app:login')


@login_required
def home(request):
    """Vue principale affichant tous les résultats avec pagination et recherche"""
    # Récupération des paramètres de recherche
    search_query = request.GET.get('q', '')
    classe_filter = request.GET.get('classe', '')
    section_filter = request.GET.get('section', '')
    annee_filter = request.GET.get('annee', '')

    # Filtrage des résultats
    records = Resultat.objects.select_related('eleve', 'classe', 'section', 'annee_scolaire')

    if search_query:
        records = records.filter(
            Q(eleve__nom_complet__icontains=search_query) |
            Q(classe__nom__icontains=search_query) |
            Q(section__nom__icontains=search_query) |
            Q(annee_scolaire__annee__icontains=search_query)
        )

    if classe_filter:
        records = records.filter(classe__nom=classe_filter)

    if section_filter:
        records = records.filter(section__nom=section_filter)

    if annee_filter:
        records = records.filter(annee_scolaire__annee=annee_filter)

    # Pagination
    paginator = Paginator(records, 25)  # 25 résultats par page
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    # Récupération des valeurs distinctes pour les filtres
    classes = Classe.objects.values_list('nom', flat=True).distinct().order_by('nom')
    sections = Section.objects.values_list('nom', flat=True).distinct().order_by('nom')
    annees = AnneeScolaire.objects.values_list('annee', flat=True).distinct().order_by('-annee')

    context = {
        'page_obj': page_obj,
        'search_query': search_query,
        'classe_filter': classe_filter,
        'section_filter': section_filter,
        'annee_filter': annee_filter,
        'classes': classes,
        'sections': sections,
        'annees': annees,
        'total_records': records.count(),
    }

    return render(request, 'palmares_app/home.html', context)


def export_pdf(request):
    """Export des résultats filtrés en PDF"""
    # Récupération des mêmes filtres que la vue principale
    search_query = request.GET.get('q', '')
    classe_filter = request.GET.get('classe', '')
    section_filter = request.GET.get('section', '')
    annee_filter = request.GET.get('annee', '')

    records = Resultat.objects.select_related('eleve', 'classe', 'section', 'annee_scolaire')

    if search_query:
        records = records.filter(
            Q(eleve__nom_complet__icontains=search_query) |
            Q(classe__nom__icontains=search_query) |
            Q(section__nom__icontains=search_query) |
            Q(annee_scolaire__annee__icontains=search_query)
        )

    if classe_filter:
        records = records.filter(classe__nom=classe_filter)

    if section_filter:
        records = records.filter(section__nom=section_filter)

    if annee_filter:
        records = records.filter(annee_scolaire__annee=annee_filter)

    # Création du PDF
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter)
    elements = []

    # Styles
    styles = getSampleStyleSheet()
    title_style = styles['Heading1']

    # Titre
    title = Paragraph("Résultats des Étudiants", title_style)
    elements.append(title)
    elements.append(Paragraph("<br/>", styles['Normal']))

    # Données du tableau
    data = [['Nom Complet', 'Pourcentage', 'Classe', 'Section', 'Année Scolaire']]

    for record in records:
        data.append([
            record.eleve.nom_complet,
            f"{record.pourcentage}%" if record.pourcentage is not None else "-",
            record.classe.nom,
            record.section.nom,
            record.annee_scolaire.annee
        ])

    # Création du tableau
    table = Table(data)
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 14),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))

    elements.append(table)

    # Génération du PDF
    doc.build(elements)
    buffer.seek(0)

    response = HttpResponse(buffer, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="resultats_etudiants.pdf"'

    return response


@login_required
def import_logs(request):
    """Vue pour afficher et gérer les logs d'importation"""
    logs_dir = os.path.join('media', 'import_errors')

    # Créer le répertoire s'il n'existe pas
    os.makedirs(logs_dir, exist_ok=True)

    # Lister tous les fichiers de log
    log_files = []
    if os.path.exists(logs_dir):
        for filename in os.listdir(logs_dir):
            if filename.endswith('.csv'):
                filepath = os.path.join(logs_dir, filename)
                stat = os.stat(filepath)
                log_files.append({
                    'filename': filename,
                    'filepath': filepath,
                    'size': stat.st_size,
                    'modified': datetime.fromtimestamp(stat.st_mtime),
                    'url': f'/media/import_errors/{filename}'
                })

    # Trier par date de modification (plus récent en premier)
    log_files.sort(key=lambda x: x['modified'], reverse=True)

    context = {
        'log_files': log_files,
        'total_logs': len(log_files)
    }

    return render(request, 'palmares_app/import_logs.html', context)


@login_required
def download_log(request, filename):
    """Vue pour télécharger un fichier de log spécifique"""
    logs_dir = os.path.join('media', 'import_errors')
    filepath = os.path.join(logs_dir, filename)

    # Vérifier que le fichier existe et est dans le bon répertoire
    if not os.path.exists(filepath) or not filepath.startswith(logs_dir):
        raise Http404("Fichier de log non trouvé")

    # Vérifier que c'est bien un fichier CSV
    if not filename.endswith('.csv'):
        raise Http404("Type de fichier non autorisé")

    # Lire le fichier et le retourner
    with open(filepath, 'rb') as f:
        response = HttpResponse(f.read(), content_type='text/csv')
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        return response
