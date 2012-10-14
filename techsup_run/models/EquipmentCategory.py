# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Категория узла
class EquipmentCategory(models.Model):
    name  = models.CharField(max_length=s.NODE_CATEGORY_NAME_LENGTH)
    
    class Meta:
        app_label = 'techsup_run'
        db_table  = 'equipment_category'
    