from django.urls import path
from . import views

app_name = 'palmares_app'

urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('', views.home, name='home'),
    path('export-pdf/', views.export_pdf, name='export_pdf'),
    path('import-logs/', views.import_logs, name='import_logs'),
    path('download-log/<str:filename>/', views.download_log, name='download_log'),
]