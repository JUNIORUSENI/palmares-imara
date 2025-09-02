from django.db import models


class AnneeScolaire(models.Model):
    """Modèle pour les années scolaires"""
    annee = models.CharField(
        max_length=9,
        unique=True,
        verbose_name="Année scolaire",
        help_text="Format: 2023-2024"
    )

    class Meta:
        verbose_name = "Année scolaire"
        verbose_name_plural = "Années scolaires"
        ordering = ['-annee']

    def __str__(self):
        return self.annee


class Classe(models.Model):
    """Modèle pour les classes"""
    nom = models.CharField(
        max_length=100,
        unique=True,
        verbose_name="Classe",
        help_text="Nom de la classe (ex: 6ème A, Terminale S)"
    )

    class Meta:
        verbose_name = "Classe"
        verbose_name_plural = "Classes"
        ordering = ['nom']

    def __str__(self):
        return self.nom


class Section(models.Model):
    """Modèle pour les sections"""
    nom = models.CharField(
        max_length=100,
        unique=True,
        verbose_name="Section",
        help_text="Nom de la section (ex: Scientifique, Littéraire, Economique)"
    )

    class Meta:
        verbose_name = "Section"
        verbose_name_plural = "Sections"
        ordering = ['nom']

    def __str__(self):
        return self.nom


class Eleve(models.Model):
    """Modèle pour les élèves"""
    nom_complet = models.CharField(
        max_length=255,
        unique=True,
        verbose_name="Nom complet",
        help_text="Nom et prénom complet de l'élève",
        db_index=True
    )

    class Meta:
        verbose_name = "Élève"
        verbose_name_plural = "Élèves"
        ordering = ['nom_complet']

    def __str__(self):
        return self.nom_complet


class Resultat(models.Model):
    """Modèle pour les résultats des élèves"""
    eleve = models.ForeignKey(
        Eleve,
        on_delete=models.CASCADE,
        verbose_name="Élève",
        related_name='resultats'
    )
    annee_scolaire = models.ForeignKey(
        AnneeScolaire,
        on_delete=models.PROTECT,
        verbose_name="Année scolaire",
        related_name='resultats'
    )
    classe = models.ForeignKey(
        Classe,
        on_delete=models.PROTECT,
        verbose_name="Classe",
        related_name='resultats'
    )
    section = models.ForeignKey(
        Section,
        on_delete=models.PROTECT,
        verbose_name="Section",
        related_name='resultats'
    )
    pourcentage = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        verbose_name="Pourcentage",
        help_text="Pourcentage obtenu",
        null=True,
        blank=True
    )
    date_import = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Date d'import"
    )

    class Meta:
        verbose_name = "Résultat"
        verbose_name_plural = "Résultats"
        ordering = ['-pourcentage', 'eleve__nom_complet']
        unique_together = ['eleve', 'annee_scolaire']

    def __str__(self):
        return f"{self.eleve.nom_complet} - {self.pourcentage}% - {self.classe.nom}"
