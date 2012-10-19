BEGIN {
  FORMAT = "%c.%c.%s\n"
}

{
  printf FORMAT, tolower(substr($1, 0, 1)),
                 tolower(substr($2, 0, 1)),
                 tolower(gensub("'", "", "g", $3));
}
