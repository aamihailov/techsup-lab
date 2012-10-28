# -*- coding: utf-8 -*-


from django.utils.datetime_safe import date
from django.shortcuts import render_to_response
from django.http import HttpResponse

from techsup_run.models.Employee import Employee
from techsup_run.models.Equipment import Equipment
from techsup_run.models.EquipmentOperation import EquipmentOperation
from techsup_run.models.EmployeeOperation import EmployeeOperation
from techsup_run.models.EquipmentModel import EquipmentModel


def get_or_none(model, **kwargs):
    try:
        return model.objects.get(**kwargs)
    except model.DoesNotExist:
        return None


def home(request, r):
    return render_to_response('test.html', {'employees_list' : Employee.objects.filter(role=r)})
    #return render_to_response('test.html', {'employees_list' : EquipmentModel.objects.filter(category_id=EquipmentCategory.objects.get(name='Ноутбук'))})

def test(request):
    return render_to_response('test.html', {'employees_list' : EquipmentModel.objects.filter(category_id = 3)})

def many(request, gt, lt):
    return render_to_response('test.html', {'employees_list' : Employee.objects.filter(role__gte=gt, role__lte=lt)})

def maybe_owners(request, printer_id):
    try:
        pr = Equipment.objects.get(serial_number=printer_id)
    except Equipment.DoesNotExist:
        return HttpResponse()

    A = EquipmentOperation.objects.get(equipment=pr, eq_oper_type_id=1).datetime.date()
    B = get_or_none(EquipmentOperation, equipment=pr, eq_oper_type_id=2)
    if B == None:
        B = date('2020-12-31')
    else:
        B = B.datetime.date( )
    
    query = '''
    SELECT * FROM employee
    WHERE id NOT IN (
      SELECT employee_id FROM employee_operation
      WHERE type_id = 1 AND date < %s
      UNION
      SELECT employee_id FROM employee_operation
      WHERE type_id = 2 AND date > %s
    )'''  
    
    el = Employee.objects.raw(query, [B, A])

    return render_to_response('test.html', {'employees_list' : el})
    return HttpResponse('%s' % printer_id)

def owners(request, printer_id, snils):
    try:
        A = EquipmentOperation.objects.get(equipment__serial_number=printer_id, eq_oper_type_id=1).datetime.date()
        B = get_or_none(EquipmentOperation, equipment__serial_number=printer_id, eq_oper_type_id=2)
        if B != None:
            B = B.datetime.date( )
    except EquipmentOperation.DoesNotExist:
        A = date( 1950, 01, 01 )
        B = date( 2020, 12, 31 )

    try:
        C = EmployeeOperation.objects.get(employee__snils=snils, type_id=1).date
        D = get_or_none(EmployeeOperation, employee__snils=snils, type_id=1)
    except:
        C = date( 1950, 01, 01 )
        D = date( 2020, 12, 31 )

    beg = '%s' % max([A,C])
    if B == None:
        if D == None:
            end = 'NULL';
        else:
            end = '%s' % D
    else:
        if D == None:
            end = '%s' % B
        else:
            end = '%s' % min([B,D])
    
    return HttpResponse('%s\t%s' % ( beg, end ) )
