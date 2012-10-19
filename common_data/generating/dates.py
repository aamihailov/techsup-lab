# -*- coding: utf-8 -*-

from datetime import timedelta, date
from random import randint

n = 2938

for i in xrange( n ):
    date_in  = date.today() - timedelta( days=randint( 0, 16000 ) )
    date_out = date_in      + timedelta( weeks=randint( 25, 500 ) )
    print '%s\t%s' % ( date_in, date_out ),
    hb = timedelta( weeks=26 )
    hl = timedelta( weeks=2  )
    while date_in + hb + hl < date_out:
        date_b = date_in + hb
        date_e = date_in + hb + hl
        print '\t%s\t%s' % ( date_b, date_e ),
        hb += timedelta( weeks=26 )
    print