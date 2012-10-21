

open(names,       "names.dat");
open(phones,      "phones.dat");
open(addresses,   "addresses.dat");
open(logins,      "logins.dat");
open(passwords,   "passwords.dat");
open(dates,		  "dates_in.dat");
open(snils,		  "snils.dat");

$format = "CALL add_employee('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');\n";

@names       = <names>;
@phones      = <phones>;
@addresses   = <addresses>;
@logins      = <logins>;
@passwords   = <passwords>;
@dates       = <dates>;
@snils       = <snils>;

sub role {
  %roles = ( 1 => "Бухгалтер",
             2 => "Инженер", 
             3 => "Старший лаборант", 
             4 => "Младший лаборант", 
             5 => "Старший научный сотрудник", 
             6 => "Младший научный сотрудник",
             7 => "Техник",
             8 => "Администратор" );
  if ( $_[0] < 294 ) {
    return $roles{ 7 };
  } elsif ( $_[0] < 442 ) {
    return $roles{ 1 };
  }
  return $roles{ 2 + int rand 5 };  # 2..6
}

sub dep {
  %dep = ( 1  => "НИИ Физиологии СО РАМН",
           2  => "Сибирский компьютер", 
           3  => "Мобильный Сервис", 
   	       4  => "Виста Сервис", 
           5  => "Региональный Сервисный Центр", 
           6  => "Звёздочка", 
           7  => "Очумелые ручки", 
           8  => "Fast help",
           9  => "Домашний мастер",
           10 => "Красный Робот",
           11 => "АСЦ ООО Мобайл-Сервис" );
  if ( $_[0] >= 294 ) {
    return $dep{ 1 };
  }
  return $dep{ 2 + int rand 10 };  #2..11
}

$n = scalar @names;

for ( $i = 0; $i < $n; $i++ ) {
  $sn = @snils[$i];       chomp $sn;
  $na = @names[$i];       chomp $na;
  $ph = @phones[$i];      chomp $ph;
  $ad = @addresses[$i];   chomp $ad;
  $lo = @logins[$i];      chomp $lo;
  $pa = @passwords[$i];   chomp $pa;
  $ro = role $i;
  $de = dep  $i;
  $da = @dates[$i];       chomp $da;
  printf $format, $sn, $na, $ph, $ad, $lo, $pa, $ro, $de, $da; 
}
