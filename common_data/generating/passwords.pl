

use Digest::MD5 qw ( md5_hex );

open(logins, "logins.dat");

@logins = <logins>;
$n = scalar @logins;

for ( $i = 0; $i < $n; $i++ ) {
  printf "%s\n", md5_hex @logins[$i];
}
