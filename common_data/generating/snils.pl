

$n = 2938;

$fmt = "%03d-%03d-%03d %02d\n";

for ( $i = 0; $i < $n; $i++ ) {
  @digits = ( int rand 1000, int rand 1000, int rand 1000 );
#  print $digits[1];
  grep $sum += $_, @digits;
  printf $fmt, $digits[0], $digits[1], $digits[2], $sum % 100;
}
