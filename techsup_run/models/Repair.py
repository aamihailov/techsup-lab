# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Ремонт
class Repair(models.Model):
    equipment_assisment  = models.CharField(max_length=s.EQ_ASS_NAME_LENGTH)
    work_price           = models.FloatField()
    detail_price         = models.FloatField()
    detail_model         = models.ForeignKey('DetailModel')
    equpment_operation   = models.ForeignKey('EquipmentOperation')
    
    class Meta:
        app_label = 'techsup_run'
    