# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Приоритет заявки
class TaskPriority(models.Model):
    name  = models.CharField(max_length=s.TASK_PRIORITY_NAME_LENGTH, unique=True)
    
    class Meta:
        app_label = 'techsup_run'
        db_table = 'task_priority'
    