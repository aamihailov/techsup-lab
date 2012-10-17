# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Группы (права)
class RightsGroup(models.Model):
    name    = models.CharField(max_length=s.RIGHTS_NAME_LENGTH, unique=True)
    rights  = models.CharField(max_length=s.RIGHTS_LENGTH)
    
    class Meta:
        app_label = 'techsup_run'
        db_table = 'rights_group'
    