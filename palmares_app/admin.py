from django.contrib import admin
from django.urls import path
from django.shortcuts import render, redirect
from django.contrib import messages
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from .models import AnneeScolaire, Classe, Section, Eleve, Resultat
import openpyxl
import os


@admin.register(AnneeScolaire)
class AnneeScolaireAdmin(admin.ModelAdmin):
    list_display = ('annee',)
    search_fields = ('annee',)
    ordering = ('-annee',)


@admin.register(Classe)
class ClasseAdmin(admin.ModelAdmin):
    list_display = ('nom',)
    search_fields = ('nom',)
    ordering = ('nom',)


@admin.register(Section)
class SectionAdmin(admin.ModelAdmin):
    list_display = ('nom',)
    search_fields = ('nom',)
    ordering = ('nom',)


@admin.register(Eleve)
class EleveAdmin(admin.ModelAdmin):
    list_display = ('nom_complet',)
    search_fields = ('nom_complet',)
    ordering = ('nom_complet',)


class ResultatAdmin(admin.ModelAdmin):
    list_display = ('eleve', 'pourcentage', 'classe', 'section', 'annee_scolaire', 'date_import')
    list_filter = ('classe', 'section', 'annee_scolaire', 'date_import')
    search_fields = ('eleve__nom_complet', 'classe__nom', 'section__nom', 'annee_scolaire__annee')
    ordering = ('-pourcentage', 'eleve__nom_complet')
    readonly_fields = ('date_import',)
    raw_id_fields = ('eleve', 'annee_scolaire', 'classe', 'section')
    change_list_template = 'admin/palmares_app/resultat/change_list.html'

    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        extra_context['import_url'] = 'import-excel/'
        return super().changelist_view(request, extra_context)

    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('import-excel/', self.admin_site.admin_view(self.import_excel), name='import_excel'),
        ]
        return custom_urls + urls

    def import_excel(self, request):
        if request.method == 'POST' and request.FILES.get('excel_file'):
            excel_file = request.FILES['excel_file']

            if not excel_file.name.endswith(('.xlsx', '.xls')):
                messages.error(request, "Veuillez sélectionner un fichier Excel valide (.xlsx ou .xls)")
                return redirect('admin:palmares_app_resultat_changelist')

            try:
                # Save file temporarily
                file_name = default_storage.save('temp_excel.xlsx', ContentFile(excel_file.read()))
                file_path = default_storage.path(file_name)

                # Process Excel file
                workbook = openpyxl.load_workbook(file_path)
                sheet = workbook.active

                imported_count = 0
                updated_count = 0
                errors = []
                error_details = []

                # Skip header row
                for row_num, row in enumerate(sheet.iter_rows(min_row=2, values_only=True), start=2):
                    if not row[0]:  # Skip empty rows
                        continue

                    try:
                        nom_complet, pourcentage, classe_nom, section_nom, annee_scolaire = row[:5]

                        # Validate required fields (pourcentage is now optional)
                        if not all([nom_complet, classe_nom, section_nom, annee_scolaire]):
                            error_msg = f"Ligne {row_num}: Champs requis manquants (Nom complet, Classe, Section, Année scolaire sont obligatoires)"
                            errors.append(error_msg)
                            error_details.append({
                                'ligne': row_num,
                                'donnees': row,
                                'erreur': error_msg
                            })
                            continue

                        # Validate pourcentage if provided
                        if pourcentage is not None:
                            try:
                                pourcentage_val = float(pourcentage)
                                if not (0 <= pourcentage_val <= 100):
                                    error_msg = f"Ligne {row_num}: Pourcentage doit être entre 0 et 100"
                                    errors.append(error_msg)
                                    error_details.append({
                                        'ligne': row_num,
                                        'donnees': row,
                                        'erreur': error_msg
                                    })
                                    continue
                            except (ValueError, TypeError):
                                error_msg = f"Ligne {row_num}: Pourcentage doit être un nombre valide"
                                errors.append(error_msg)
                                error_details.append({
                                    'ligne': row_num,
                                    'donnees': row,
                                    'erreur': error_msg
                                })
                                continue
                        else:
                            pourcentage_val = None

                        # Get or create related objects
                        annee_obj, created = AnneeScolaire.objects.get_or_create(
                            annee=str(annee_scolaire).strip()
                        )

                        classe_obj, created = Classe.objects.get_or_create(
                            nom=str(classe_nom).strip()
                        )

                        section_obj, created = Section.objects.get_or_create(
                            nom=str(section_nom).strip()
                        )

                        eleve_obj, created = Eleve.objects.get_or_create(
                            nom_complet=str(nom_complet).strip()
                        )

                        # Create or update result
                        resultat, created = Resultat.objects.get_or_create(
                            eleve=eleve_obj,
                            annee_scolaire=annee_obj,
                            defaults={
                                'classe': classe_obj,
                                'section': section_obj,
                                'pourcentage': pourcentage_val
                            }
                        )

                        if not created:
                            # Update existing result
                            resultat.classe = classe_obj
                            resultat.section = section_obj
                            if pourcentage_val is not None:
                                resultat.pourcentage = pourcentage_val
                            resultat.save()
                            updated_count += 1
                        else:
                            imported_count += 1

                    except Exception as e:
                        error_msg = f"Ligne {row_num}: Erreur inattendue - {str(e)}"
                        errors.append(error_msg)
                        error_details.append({
                            'ligne': row_num,
                            'donnees': row,
                            'erreur': error_msg
                        })

                # Create error log file if there are errors
                error_log_path = None
                if error_details:
                    import csv
                    from datetime import datetime

                    error_log_filename = f'import_errors_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
                    error_log_path = os.path.join('media', 'import_errors', error_log_filename)

                    # Ensure directory exists
                    os.makedirs(os.path.dirname(error_log_path), exist_ok=True)

                    with open(error_log_path, 'w', newline='', encoding='utf-8') as csvfile:
                        fieldnames = ['Ligne', 'Nom complet', 'Pourcentage', 'Classe', 'Section', 'Année scolaire', 'Erreur']
                        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                        writer.writeheader()

                        for error in error_details:
                            row_data = error['donnees']
                            writer.writerow({
                                'Ligne': error['ligne'],
                                'Nom complet': row_data[0] if len(row_data) > 0 else '',
                                'Pourcentage': row_data[1] if len(row_data) > 1 else '',
                                'Classe': row_data[2] if len(row_data) > 2 else '',
                                'Section': row_data[3] if len(row_data) > 3 else '',
                                'Année scolaire': row_data[4] if len(row_data) > 4 else '',
                                'Erreur': error['erreur']
                            })

                # Clean up temp file
                os.remove(file_path)

                success_msg = []
                if imported_count > 0:
                    success_msg.append(f"{imported_count} résultats importés")
                if updated_count > 0:
                    success_msg.append(f"{updated_count} résultats mis à jour")

                if success_msg:
                    messages.success(request, " | ".join(success_msg))

                if errors:
                    for error in errors[:3]:  # Show first 3 errors
                        messages.warning(request, error)
                    if len(errors) > 3:
                        messages.warning(request, f"... et {len(errors) - 3} autres erreurs")

                    if error_log_path:
                        log_filename = os.path.basename(error_log_path)
                        messages.info(request,
                            f'Fichier de log des erreurs créé: <a href="/download-log/{log_filename}/" class="underline font-medium">Télécharger {log_filename}</a>',
                            extra_tags='safe'
                        )

            except Exception as e:
                messages.error(request, f"Erreur lors de l'import: {str(e)}")

            return redirect('admin:palmares_app_resultat_changelist')

        return render(request, 'admin/palmares_app/resultat/import_excel.html', {
            'title': 'Importer depuis Excel'
        })


admin.site.register(Resultat, ResultatAdmin)
