# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Модель оборудования
class EquipmentModel(models.Model):
    name  = models.CharField(max_length=s.EQ_MODEL_NAME_LENGTH)
    
    class Meta:
        app_label = 'techsup_run'
