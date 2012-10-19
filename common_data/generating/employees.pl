

open(names,       "names.dat");
open(phones,      "phones.dat");
open(addresses,   "addresses.dat");
open(logins,      "logins.dat");
open(passwords,   "passwords.dat");
open(roles,       "roles.dat");
open(departments, "departments.dat");

sub random_date {
  "CURRENT_DATE - " . int rand 16000;
}

$format = "CALL add_employee_with_date('%s', '%s', '%s', '%s', '%s', '%s', '%s', %s);\n";

@names       = <names>;
@phones      = <phones>;
@addresses   = <addresses>;
@logins      = <logins>;
@passwords   = <passwords>;
@roles       = <roles>;
@departments = <departments>;

# Техники
for ( $i = 0; $i < 294; $i++ ) {
  printf format, @names[$i],
                 @phones[$i],
                 @addresses[$i],
                 @logins[$i],
                 @passwords[$i],
                 @roles[$i],
                 @departments[$i],
                 random_date;
}
