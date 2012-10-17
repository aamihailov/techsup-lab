# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Сфера деятельности
class DepartmentActivitySphere(models.Model):
    name  = models.CharField(max_length=s.ACTIVITY_SPHERE_NAME_LENGTH, unique=True)

    class Meta:
        app_label = 'techsup_run'
        db_table = 'department_activity_sphere'
