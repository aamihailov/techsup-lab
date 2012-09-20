# -*- coding: utf-8 -*-

from django.db import models

# Связь сотрудника и оборудования
class EmployeeEquipmentCommunication(models.Model):
    employee   = models.ForeignKey('Employee')
    equipment  = models.ForeignKey('Equipment')
    
    class Meta:
        app_label = 'techsup_run'
    