# -*- coding: utf-8 -*-

from django.db import models

# Связь сотрудника и оборудования
class EquipmentOwner(models.Model):
    start_datetime  = models.DateTimeField()
    finish_datetime = models.DateTimeField(null=True)
    equipment       = models.ForeignKey('Equipment')
    employee        = models.ForeignKey('Employee')
     
    class Meta:
        app_label = 'techsup_run'
        db_table  = 'equipment_owner'
#       unique_together = ('equipment', 'employee')

