# -*- coding: utf-8 -*-

from django.db import models

# Техник
class Technics(models.Model):
    employee = models.ForeignKey('Employee', primary_key=True)
    
    class Meta:
        app_label = 'techsup_run'
        db_table = 'technics'
    
