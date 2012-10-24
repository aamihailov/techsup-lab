# -*- coding: utf-8 -*-

from datetime import timedelta, date
from dateutil import parser
from random import randint

din  = open("dates_in.dat", 'r')
dout = open("dates_out.dat", 'r')

n = 2938

for i in xrange( n ):
    date_in = parser.parse(din.readline()).date()
    date_out = parser.parse(dout.readline()).date()
#    laptop = timedelta( weeks = randint( 150, 200 ) )
#    if date_in + laptop < date_out:
#        print '%s\t%s' % ( date_in + laptop, date_out )
#    else:
#        print
    delta = timedelta( weeks = randint( 200, 450 ) )
    while date_in + delta < date_out:
        print '%s\t%s\t' % (date_in, date_in + delta),
        date_in += delta
        delta = timedelta( weeks = randint( 200, 450 ) )
    print '%s\t%s' % (date_in, date_out)
    