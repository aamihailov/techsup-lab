# -*- coding: utf-8 -*-

from django.db import models

# Администратор
class Admins(models.Model):
    employee = models.ForeignKey('Employee', primary_key=True)
    
    class Meta:
        app_label = 'techsup_run'
        db_table = 'admins'
    
