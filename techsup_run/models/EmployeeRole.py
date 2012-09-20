# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Должность сотрудника
class EmployeeRole(models.Model):
    name = models.CharField(max_length=s.EMPLOYEE_ROLE_NAME_LENGTH)

    class Meta:
        app_label = 'techsup_run'
    