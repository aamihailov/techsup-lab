# -*- coding: utf-8 -*-

import random
import linecache
import httplib

c  = httplib.HTTPConnection('127.0.0.1', 8000)
f  = open('printer_serial_number.dat','r')
f2 = open('add_printer_owner.sql','w')
f3 = open('delete_printer_owner.sql','w')
for eq in range(0, 230):
    # вернули снилсы товарищей, которые могли пользоваться этим оборудованием
    req = "/maybe_owners/" + ''.join(str(linecache.getline('printer_serial_number.dat', eq+1)).splitlines()) + "/"
    c.request("GET", req)
    owners = c.getresponse() 
    # переписать в массив
    owners = owners.read().split("\n")

    num = min(len(owners), 25) -1

    for i in range( num ):
        ind = random.randint(0, len(owners)-2)
        # для конкретного человека, когда он им мог пользоваться
        req = "/owners/" + ''.join(str(linecache.getline('printer_serial_number.dat', eq+1)).splitlines()) + "/" + owners[ind].replace(' ', '%20') + "/"
        c.request("GET", req)
        dates = c.getresponse() 
        # переписать в массив
        dates = dates.read().split("\n")

        add_eq_owner  =  'CALL add_equipment_owner( '
        add_eq_owner  += '\'' + owners[ind]                                                                     + '\', '
        add_eq_owner  += '\'' + ''.join(str(linecache.getline('printer_serial_number.dat', eq+1)).splitlines()) + '\', '
        add_eq_owner  += '\'' + str(dates[0])                                                                   + '\' '
        add_eq_owner  += ');' + '\n'

        del_eq_owner  =  'CALL delete_equipment_owner( '
        del_eq_owner  += '\'' + owners[ind]                                                                     + '\', '
        del_eq_owner  += '\'' + ''.join(str(linecache.getline('printer_serial_number.dat', eq+1)).splitlines()) + '\', '
        del_eq_owner  += '\'' + str(dates[1])                                                                   + '\' '
        del_eq_owner  += ');' + '\n'
        
        f2.write(add_eq_owner)
        f3.write(del_eq_owner)
f.close()
f2.close()
f3.close()
