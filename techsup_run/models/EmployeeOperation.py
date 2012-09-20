# -*- coding: utf-8 -*-

from django.db import models

# Операции с сотрудниками
class EmployeeOperation(models.Model):
    type        = models.ForeignKey('EmployeeOperationType')
    employee    = models.ForeignKey('Employee')
    department  = models.ForeignKey('Department')
    
    class Meta:
        app_label = 'techsup_run'
    
    