# -*- coding: utf-8 -*-

from random import randint
from datetime import date, timedelta

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
      WHERE type_id = 2 AND date < %s
      UNION
      SELECT employee_id FROM employee_operation
      WHERE type_id = 1 AND date > %s
    )'''  
    
    el = Employee.objects.raw(query, [A, B])

    return render_to_response('maybe_owners.html', {'employees_list' : el})



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
        D = get_or_none(EmployeeOperation, employee__snils=snils, type_id=2)
        if D != None:
            D = D.date
    except:
        C = date( 1950, 01, 01 )
        D = date( 2020, 12, 31 )

    beg = '%s' % max([A,C])
    if B == None:
        if D == None:
            end = 'NULL'
        else:
            end = '%s' % D
    else:
        if D == None:
            end = '%s' % B
        else:
            end = '%s' % min([B,D])

    if end < beg:
        end = 'NULL'
        beg = 'NULL'
        
    return HttpResponse('%s\n%s' % ( beg, end ) )



def task(request, eqid):
    response = ""
    beg_date = EquipmentOperation.objects.get(equipment__serial_number=eqid, eq_oper_type_id=1).datetime.date()
    beg_date += timedelta( weeks = randint(10, 300) )
    today = date(2012, 10, 20)
    
    eq = Equipment.objects.get(serial_number = eqid)
    owners = eq.owner.all()
    if len( owners ) == 0:
        return HttpResponse( '' ) 
    
    query = '''
    SELECT * FROM employee
    WHERE id NOT IN (
      SELECT employee_id FROM employee_operation
      WHERE type_id = 2 AND date < %s
      UNION
      SELECT employee_id FROM employee_operation
      WHERE type_id = 1 AND date > %s
    )
    AND role_id = 7'''  


    while beg_date < today:
        owner = owners[randint(0,len(owners)-1)]
        date_add  = '%s' % beg_date; snils_add = owner.snils
        beg_date += timedelta( days = randint(0, 5) )
        
        tech = Employee.objects.raw(query, [beg_date, beg_date + timedelta( weeks = 4 )])
        tech = [t for t in tech]
        if len( tech ) == 0:
            tch = owner
            cls = owner
        else:
            tch = tech[randint(0,len(tech)-1)]
            cls = tech[randint(0,len(tech)-1)]
        date_own  = '%s' % beg_date; snils_own = tch.snils
        beg_date += timedelta( days = randint(0, 5) )
        
        if randint(0,3) == 0:
            date_rep  = '%s' % beg_date; snils_rep = 'repair' 
            beg_date += timedelta( days = randint(0, 5) )
        else:
            date_rep  = '2020-01-01';    snils_rep = 'not-a-repair'
        date_cls  = '%s' % beg_date; snils_cls = cls.snils
        beg_date += timedelta( weeks = randint(10, 300) )
        
        add = "%s\t%s" % (date_add, snils_add)
        own = "%s\t%s" % (date_own, snils_own)
        rep = "%s\t%s" % (date_rep, snils_rep)
        cls = "%s\t%s" % (date_cls, snils_cls)
        response += "%s\n%s\n%s\n%s\n\n" % (add, own, rep, cls)

    return HttpResponse(response)



def equipment_list(request):
    el = Equipment.objects.all()
    return render_to_response('equipment_list.html', {'equipment_list' : el})
