from django.shortcuts import render_to_response

from techsup_run.models.Employee import Employee

def home(request, r):
    return render_to_response('test.html', {'employees_list' : Employee.objects.filter(role=r)})

def many(request, gt, lt):
    return render_to_response('test.html', {'employees_list' : Employee.objects.filter(role__gte=gt, role__lte=lt)})
