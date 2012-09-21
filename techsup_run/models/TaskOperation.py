# -*- coding: utf-8 -*-

from django.db import models

# Операции с заявкой
class TaskOperation(models.Model):
    task      = models.ForeignKey('Task')
    technic   = models.ForeignKey('Employee', related_name='technic_id')
    state     = models.ForeignKey('TaskState')
    date      = models.DateField()
    
    class Meta:
        app_label = 'techsup_run'
    
    
    