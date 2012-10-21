

open(snils, "snils.dat");
open(dates, "dates_out.dat");

@dates = <dates>;
@snils = <snils>;

$format = "CALL delete_employee('%s', '%s');\n";

$today  = "2012-10-20";

$n = scalar @snils;

for ( $i = 0; $i < $n; $i++ ) {
  $sn = @snils[$i]; chomp $sn;
  $da = @dates[$i]; chomp $da;
  if ( $da lt $today ) {
    printf $format, $sn, $da;
  }
}