# -*- coding: utf-8 -*-

from django.db import models

# Операции с оборудованием
class EquipmentOperation(models.Model):
    equipment    = models.ForeignKey('Equipment')
    eq_oper_type = models.ForeignKey('EquipmentOperationType')
    date         = models.DateField()
    
    class Meta:
        app_label = 'techsup_run'
    