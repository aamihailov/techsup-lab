# -*- coding: utf-8 -*-

from django.core.management.base import BaseCommand
import techsup_run.models as tsm

from django.db import connection

class BaseFill(object):
    def __init__(self, *args, **kwargs):
        self.T    = None
        self.vals = []

    def handle(self):
        for val in self.vals:
            item = self.T(val)
            item.save()
            print connection.queries[-1]['sql']
            
class EmployeeRoleFill(BaseFill):
    def __init__(self, *args, **kwargs):
        self.T    = lambda val: tsm.EmployeeRole.EmployeeRole(name = val)
        self.vals = [
                     u'Бухгалтер', 
                     u'Инженер',
                     u'Старший лаборант',
                     u'Младший лаборант',
                     u'Старший научный сотрудник',
                     u'Младший научный сотрудник'
                    ]
    
class RightsGroupFill(BaseFill):
    def __init__(self, *args, **kwargs):
        self.T    = lambda val: tsm.RightsGroup.RightsGroup(name = val[0], rights = val[1])
        self.vals = [
                     (u'Администратор', 'rw'),
                     (u'Техник', 'rw'),
                     (u'Пользователь', 'r') 
                    ]

class EmployeeOperationTypeFill(BaseFill):
    def __init__(self, *args, **kwargs):
        self.T    = lambda val: tsm.EmployeeOperationType.EmployeeOperationType(name = val)
        self.vals = [
                     u'Принят',
                     u'Уволен',
                     u'Отправлен в отпуск',
                     u'Отозван из отпуска' 
                    ]

class DepartmentActivitySphereFill(BaseFill):
    def __init__(self, *args, **kwargs):
        self.T    = lambda val: tsm.DepartmentActivitySphere.DepartmentActivitySphere(name = val)
        self.vals = [
                     u'Медицинский профиль',
                     u'Технический профиль'
                    ]
        
class EquipmentOperationTypeFill(BaseFill):
    def __init__(self, *args, **kwargs):
        self.T    = lambda val: tsm.EquipmentOperationType.EquipmentOperationType(name = val)
        self.vals = [
                     u'Поступление',
                     u'Списание',
                     u'Ремонт',
                     u'Замена детали',
                     u'Перемещение на склад'
                    ]
        
class TaskPriorityFill(BaseFill):
    def __init__(self, *args, **kwargs):
        self.T    = lambda val: tsm.TaskPriority.TaskPriority(name = val)
        self.vals = [
                     u'Самый высокий',
                     u'Высокий',
                     u'Средний',
                     u'Низкий',
                     u'Cамый низкий'
                    ]
        
class TaskStateFill(BaseFill):
    def __init__(self, *args, **kwargs):
        self.T    = lambda val: tsm.TaskState.TaskState(name = val)
        self.vals = [
                     u'Новая',
                     u'Выполняется',
                     u'Активная',
                     u'Разрешена',
                     u'Закрыта'
                    ]
        
class Command(BaseCommand):
    help = 'Filling the dict entities such as categories, size-fixed groups, etc'
    
    def handle(self, *args, **options):
        FillerList = [EmployeeRoleFill, 
                      RightsGroupFill,
                      EmployeeOperationTypeFill,
                      DepartmentActivitySphereFill,
                      EquipmentOperationTypeFill,
                      TaskPriorityFill,
                      TaskStateFill]
        for Filler in FillerList:
            self.stdout.write('-- ' + Filler.__name__)
            f = Filler()
            f.handle()
            