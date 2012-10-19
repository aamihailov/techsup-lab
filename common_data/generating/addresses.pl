#!/usr/bin/perl

open(streets, "streets.dat");

@streets = <streets>;

$ns = scalar @streets;

$n  = 2954;

for( $i = 0; $i < $n; $i++ ) {
  $street = @streets[int rand $ns];
  chomp $street;
  printf "%s, %d\n", $street, 1 + int rand 40;
}

