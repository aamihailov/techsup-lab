BEGIN {
  FS = "\t";
  cat_id = 0;
  det_id = 0;
  cat_format = "INSERT INTO `equipment_category` ( `id`, `name` ) VALUES\n  (%d, \"%s\");\n";
  det_format = "INSERT INTO `equipment_model` ( `id`, `name`, `category_id` ) VALUES\n  (%d, \"%s\", %d);\n";
}

$1 == "0" {
  cat_id += 1;
  printf cat_format, cat_id, gensub("\"", "@", "g", $2);
}

$1 == "1" {
  det_id += 1;
  printf det_format, det_id, gensub("\"", "@", "g", $2), cat_id;
}

END {
  print num;
}
