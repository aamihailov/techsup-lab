DUMP = techsup_run/fixtures/initial_data.json

fill : clear
	python manage.py syncdb

clean_fill : clear
	test -e $(DUMP) && rm $(DUMP) || echo
	python manage.py syncdb
	cat common_data/sql_queries/new_queries.sql | python manage.py dbshell
	cat common_data/generating/primaries.sql    | python manage.py dbshell
	cat common_data/generating/equipment.sql    | python manage.py dbshell
	cat common_data/generating/detail.sql       | python manage.py dbshell
	cat common_data/generating/departments.sql  | python manage.py dbshell
	cat common_data/generating/employees.sql    | python manage.py dbshell
	cat common_data/generating/admin.sql    	| python manage.py dbshell
	cat common_data/generating/dates_h.sql      | python manage.py dbshell
	cat common_data/generating/dates_out.sql    | python manage.py dbshell
	python manage.py techsup_dump > $(DUMP)

clear :
	python manage.py sqlclear techsup_run | python manage.py dbshell
