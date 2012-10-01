# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Типы операций с оборудованием
class EquipmentOperationType(models.Model):
    name  = models.CharField(max_length=s.EQ_OPER_TYPE_NAME_LENGTH)
    
    class Meta:
        app_label = 'techsup_run'
        db_table = 'equipment_operation_type'
    