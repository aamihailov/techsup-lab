# -*- coding: utf-8 -*-

from django.db import models

import settings as s

# Сотрудник
class Employee(models.Model):
    name        = models.CharField(max_length=s.EMPLOYEE_NAME_LENGTH)
    phone       = models.CharField(max_length=s.EMPLOYEE_PHONE_LENGTH)
    email       = models.EmailField()
    addr        = models.CharField(max_length=s.EMPLOYEE_ADDR_LENGTH)
    login       = models.CharField(max_length=s.EMPLOYEE_LOGIN_LENGTH)    
    password    = models.CharField(max_length=s.EMPLOYEE_PASSWORD_LENGTH)
    role        = models.ForeignKey('EmployeeRole')
    group       = models.ForeignKey('RightsGroup')
     
    class Meta:
        app_label = 'techsup_run'
        db_table = 'employee'
        unique_together = (('name', 'phone'), ('login', 'password'))
    