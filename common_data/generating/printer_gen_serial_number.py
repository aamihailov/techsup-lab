# -*- coding: utf-8 -*-

import random

f = open('/home/anastass/Desktop/printer_gen/printer_serial_number.dat','w')
for num in range(0,400):
    serial_number = 'comm'
    serial_number += '-' + str(random.randint(100,999))
    serial_number += '-' + str(random.randint(1000,9999))
    serial_number += '-' + str(random.randint(10,99))
    serial_number += '-' + 'print\n'
    f.write(serial_number)
f.close()
