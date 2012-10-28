# -*- coding: utf-8 -*-

import random
import linecache
import httplib

f = open('add_equipment_printer.sql','w')
for eq in range(0, 230):
    add_eq  =  'CALL add_equipment( '
    add_eq  += '\'' + ''.join(str(linecache.getline('printer_name.dat', random.randint(1,40))).splitlines()) + '\', '
    add_eq  += '\'' + ''.join(str(linecache.getline('printer_serial_number.dat', eq+1)).splitlines())        + '\', '
    add_eq  += '\'' + ''.join(str(linecache.getline('printer_addr.dat', random.randint(1,5))).splitlines())  + '\', '
    add_eq  += '\'' + str(random.randint(656, 808))                                                          + '\', '
    add_eq  += '\'' + ''.join(str(linecache.getline('printer_in_date.dat', eq+1)).splitlines())              + '\' '
    add_eq  += ');' + '\n'
    f.write(add_eq)
f.close()  

f1 = open('delete_equipment_printer.sql','w')
for eq in range(0, 230):
    del_eq  =  'CALL delete_equipment( '
    del_eq  += '\'' + ''.join(str(linecache.getline('printer_serial_number.dat', eq+1)).splitlines()) + '\', '
    del_eq  += '\'' + ''.join(str(linecache.getline('printer_out_date.dat', eq+1)).splitlines())      + '\' '
    del_eq  += ');' + '\n'
    f1.write(del_eq)
f1.close()  
