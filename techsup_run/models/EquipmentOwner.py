# -*- coding: utf-8 -*-

from django.db import models

# Связь сотрудника и оборудования
class EquipmentOwner(models.Model):
    start_datetime  = models.DateTimeField()
    finish_datetime = models.DateTimeField(null=True)
    equipment       = models.ForeignKey('Equipment')
    employee        = models.ForeignKey('Employee')
     
    class Meta:
        app_label = 'techsup_run'
        db_table  = 'equipment_owner'
#       unique_together = ('equipment', 'employee')

    def __str__(self):
        format = '[%d : %s : %s : %d : %d]'
        return format % (self.id, self.start_datetime, self.finish_datetime, self.equipment.id, self.employee.id)
    
    def __unicode__(self):
        return self.__str__()     