# -*- coding: utf-8 -*-

import random
import linecache
import readline
import httplib

today = '2012-10-20'

f1 = open('task_name.dat', 'r')
task_names = f1.readlines()
task_num   = len(task_names)
f1.close()

for i in xrange(0, task_num):
    task_names[i] = str(task_names[i]).rstrip()

c  = httplib.HTTPConnection('127.0.0.1', 8000)

req = "/list/equipment/"
c.request("GET", req)
serial_numbers = c.getresponse()
serial_numbers = serial_numbers.read().split("\n")

f  = open('task.sql','w')
for serial_number in serial_numbers:
    req = "/task/" + serial_number + "/"
    c.request("GET", req)
    dates_snils = c.getresponse()
    # запись в массив
    dates_snils = dates_snils.read().split("\n")

    # удалить пустые строки
    while '' in dates_snils:
        dates_snils.remove('')

    # сделать многомерный массив
    for i in xrange(0, len(dates_snils)):
        dates_snils[i] = dates_snils[i].split("\t")

    for i in xrange(0, len(dates_snils), 4):
        if dates_snils[i][0] < today:
            put_new_task   = "CALL gen_put_new_task( '%s', %d, '%s', '%s', '%s' );\n" % (
                             task_names[random.randint(0, task_num)], 
                             random.randint(1, 5),
                             dates_snils[i][1],
                             dates_snils[i][0],
                             serial_number )

            f.write(put_new_task)

        if dates_snils[i+1][0] < today:
            add_task_owner = "CALL gen_add_task_owner( %d, '%s', '%s' );\n" % (
                            000, 
                            dates_snils[i+1][1],
                            dates_snils[i+1][0] )

            f.write(add_task_owner)

        if dates_snils[i+2][0] < today:
            if dates_snils[i+2][1] != 'not-a-repair':
                equipment_repair = "CALL gen_equipment_repair( %f, '%s', '%s', '%s', %d, %d );\n" % (
                                round(random.randint(100, 5000)+random.random(), 2), 
                                dates_snils[i+2][1],
                                dates_snils[i+2][0],
                                "ремонт успешно завершён",
                                random.randint(1, 836),
                                000 )
                f.write(equipment_repair)

        if dates_snils[i+3][0] < today:
            close_task     = "CALL gen_close_task( %d, '%s', '%s' );\n" % (
                            000, 
                            dates_snils[i+3][1],
                            dates_snils[i+3][0] )

            f.write(close_task)
f.close()
