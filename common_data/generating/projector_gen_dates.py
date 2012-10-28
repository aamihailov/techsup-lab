# -*- coding: utf-8 -*-

import random

f1 = open('/home/anastass/Desktop/projector_gen/commit/projector_in_date.dat','w')
f2 = open('/home/anastass/Desktop/projector_gen/commit/projector_out_date.dat','w')
for year in range(1967, 2013):
    for num in range(0, 5):
        in_date  = [year, random.randint(1,12), random.randint(1,25)]
        out_date = [year + random.randint(1,4), in_date[1], in_date[2]+random.randint(0,3)]

        str_in_date  = str(in_date[0])  + '-' + str(in_date[1])  + '-' + str(in_date[2]) + '\n'
        str_out_date = str(out_date[0]) + '-' + str(out_date[1]) + '-' + str(out_date[2]) + '\n'

        f1.write(str_in_date)
        f2.write(str_out_date)
f1.close()
f2.close()

#mv FILE FILE.bak
#cat FILE.bak | awk '!_[$0]++' | awk '{print $0}' > FILE
