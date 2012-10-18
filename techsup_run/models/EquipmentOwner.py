# -*- coding: utf-8 -*-

from django.db import models

# Связь сотрудника и оборудования
class EquipmentOwner(models.Model):
    equipment = models.ForeignKey('Equipment')
    employee  = models.ManyToManyField('Employee')
     
    class Meta:
        app_label = 'techsup_run'
        db_table = 'equipment_owner'
        unique_together = ('equipment_id', 'employee_id')

