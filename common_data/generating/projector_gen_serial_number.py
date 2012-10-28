# -*- coding: utf-8 -*-

import random

f = open('/home/anastass/Desktop/projector_gen/commit/projector_serial_number.dat','w')
for num in range(0,400):
    serial_number = 'comm'
    serial_number += '-' + str(random.randint(100,999))
    serial_number += '-' + str(random.randint(1000,9999))
    serial_number += '-' + str(random.randint(10,99))
    serial_number += '-' + 'proj\n'
    f.write(serial_number)
f.close()
