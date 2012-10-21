

open(snils, "snils.dat");
open(dates, "dates_h.dat");

@dates = <dates>;
@snils = <snils>;

$format = "CALL add_vacation('%s', '%s', '%s');\n";

$n = scalar @snils;

for ( $i = 0; $i < $n; $i++ ) {
  $sn = @snils[$i]; chomp $sn;
  $da = @dates[$i]; chomp $da;
  @da = split( "\t", $da );
  $m = scalar @da / 2;
  for ( $j = 0; $j < $m; $j++ ) {
    $beg = @da[2*$j];
    $end = @da[2*$j+1];
    if ( $j != $m-1 ) {
      chop $end;
    }
    printf $format, $sn, $beg, $end;
  }
}