# -*- coding: utf-8 -*-

from django.db import models

# Операции с заявкой
class TaskOperation(models.Model):
    work_price  = models.FloatField(null=True)
    datetime    = models.DateTimeField()
    task        = models.ForeignKey('Task')
    technic     = models.ForeignKey('Employee', related_name='technic_id')
    state       = models.ForeignKey('TaskState')
    
    class Meta:
        app_label = 'techsup_run'
        db_table = 'task_operation'
    