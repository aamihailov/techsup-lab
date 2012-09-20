# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Типы операций с сотрудниками
class EmployeeOperationType(models.Model):
    name        = models.CharField(max_length=s.EMPL_OPER_TYPE_NAME_LENGTH)
    
    class Meta:
        app_label = 'techsup_run'
    