

open(ids, "eq_tech_id.dat");
open(ltids, "eq_tech_laptop_id.dat");
open(pcids, "eq_tech_pc_id.dat");
open(snils, "snils.dat");
open(logins, "logins.dat");
open(pcs, "eq_issl_pc_dates.dat");
open(lts, "eq_issl_laptop_dates.dat");

open(ltmodels, "laptop_models.dat");
@ltmodels = <ltmodels>;

@ids    = <ids>;
@snils  = <snils>;
@logins = <logins>;

@ltids  = <ltids>;
@lts    = <lts>;

@pcids  = <pcids>;
@pcs    = <pcs>;

$id1 = 0;
$id2 = 0;

$today  = "2012-10-20";

$fmt1 = "CALL add_equipment_and_owner( '%s', '%s', '%s', '%s', '%s\%', '%s' );\n";
$fmt2 = "CALL delete_equipment( '%s', '%s' );\n";

foreach $id( @ids ) {
  $sn = @snils[$id];   chomp $sn;
  $bn = @logins[$id];  chomp $bn;
  $bn =~ s/\.//g;

  $da = @lts[$id]; chomp $da;
  @da = split( "\t", $da );
  if ( scalar @da != 0 ) {
    $mo = @ltmodels[int rand scalar @ltmodels]; chomp $mo;
    $lt = @ltids[$id1]; chomp $lt;
    printf $fmt1, $sn, $bn.'-laptop', $lt, 'room '.(100+int rand 500), $mo, @da[0];
    if ( @da[1] < $today ) {
      printf $fmt2, $lt, @da[1];
    }
    $id1 += 1;
  }
  
  $da = @pcs[$id]; chomp $da;
  @da = split( "\t", $da );
  $n = scalar @da / 2;
  for ( $i = 0; $i < $n; $i++ ) {
    $mo = 'Рабочее место оператора';
    $pc = @pcids[$id2]; chomp $pc;
    printf $fmt1, $sn, $bn.'-pc-'.($i+1), $pc, 'room '.(100+int rand 500), $mo, @da[2*$i];
    if ( @da[2*$i+1] < $today ) {
      printf $fmt2, $pc, @da[2*$i+1];
    }
    $id2 += 1;
  }
}

printf "-- ppl: %d\n-- laptops used: %d\n-- pcs used: %d\n", scalar @ids, $id1, $id2;