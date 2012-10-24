

$format = "issl-%03d-%04d-%02d-lt\n";

$n = 100000;

for ( $i = 0; $i < $n; $i++ ) {
  printf $format, 100 + int rand 800, int rand 10000, int rand 100; 
}