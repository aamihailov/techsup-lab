# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Сотрудник
class Employee(models.Model):
    name        = models.CharField(max_length=s.EMPLOYEE_NAME_LENGTH)
    phone       = models.CharField(max_length=s.EMPLOYEE_PHONE_LENGTH)
    addr        = models.CharField(max_length=s.EMPLOYEE_ADDR_LENGTH)
    login       = models.CharField(max_length=s.EMPLOYEE_LOGIN_LENGTH, null=True, unique=True)    
    password    = models.CharField(max_length=s.EMPLOYEE_PASSWORD_LENGTH, null=True)
    role        = models.ForeignKey('EmployeeRole')
         
    class Meta:
        app_label = 'techsup_run'
        db_table = 'employee'
        unique_together = ('name', 'phone')
    