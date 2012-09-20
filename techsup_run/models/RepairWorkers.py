# -*- coding: utf-8 -*-

from django.db import models

# Исполнители ремонта
class RepairWorkers(models.Model):
    repair    = models.ForeignKey('Repair')
    employee  = models.ForeignKey('Employee')
    
    class Meta:
        app_label = 'techsup_run'
    