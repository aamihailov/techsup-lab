# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Ремонт
class Repair(models.Model):
    equipment_assisment  = models.CharField(max_length=s.EQ_ASS_NAME_LENGTH)
    detail_model         = models.ForeignKey('DetailModel')
    equpment_operation   = models.ForeignKey('EquipmentOperation')
    task                 = models.ForeignKey('TaskOperation')
    
    class Meta:
        app_label = 'techsup_run'
        db_table = 'repair'
    