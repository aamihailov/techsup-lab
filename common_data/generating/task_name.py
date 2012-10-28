#-------------------------------------------------------------------------------
# Name:        generator for the module 'Task'
# Purpose:
#
# Author:      anastass
#
# Created:     25/10/2012
# Copyright:   (c) anastass 2012
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python
# -*- coding: utf-8 -*-

# эта штука генерит 630 строчек

f = open('gen.dat','w')

problems   = ['не работает устройство:','не включается устройство:','сломалось устройство:','трещит устройство:',
              'стало грязным устройство:']
devices    = ['компьютер','мышь','системный блок','монитор','принтер','МФУ',
             'оборудование из лаборатории']
reasons_to = ['из-за того, что','по причине того, что','в результате того, что']
reasons    = ['уронили','часто падало на пол','забилось пылью','забилось мусором',
             'пролили чай на устройство','неаккуратно эксплуатировали']

for problem in problems:
    for device in devices:
        for reason_to in reasons_to:
            for reason in reasons:
                str_gen = problem + ' ' + device + ' ' + reason_to + ' ' + reason + '\n'
                f.write(str_gen)

f.close()
