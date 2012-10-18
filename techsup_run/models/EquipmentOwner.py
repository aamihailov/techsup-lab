# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Связь сотрудника и оборудования
class EquipmentOwner(models.Model):
    equipment = models.ForeignKey('Equipment')
    employee  = models.ForeignKey('Employee')
     
    class Meta:
        app_label = 'techsup_run'
        db_table  = 'equipment_owner'
#        unique_together = ('equipment_id', 'employee_id')

