fill : clear
	python manage.py syncdb
	cat common_data/sql_queries/new_queries.sql             | python manage.py dbshell
	cat common_data/generating/primaries.sql                | python manage.py dbshell
	cat common_data/generating/equipment.sql                | python manage.py dbshell
	cat common_data/generating/detail.sql                   | python manage.py dbshell
	cat common_data/generating/departments.sql              | python manage.py dbshell
	cat common_data/generating/employees.sql                | python manage.py dbshell
	cat common_data/generating/admin.sql                    | python manage.py dbshell
	cat common_data/generating/dates_h.sql                  | python manage.py dbshell
	cat common_data/generating/dates_out.sql                | python manage.py dbshell
	cat common_data/generating/eq_issl.sql                  | python manage.py dbshell
	cat common_data/generating/eq_engi.sql                  | python manage.py dbshell
	cat common_data/generating/eq_oper.sql                  | python manage.py dbshell
	cat common_data/generating/eq_tech.sql                  | python manage.py dbshell
	cat common_data/generating/add_equipment_printer.sql    | python manage.py dbshell
	cat common_data/generating/delete_equipment_printer.sql | python manage.py dbshell
	cat common_data/generating/add_printer_owner.sql        | python manage.py dbshell
	cat common_data/generating/delete_printer_owner.sql     | python manage.py dbshell

clear :
	python manage.py sqlclear techsup_run 					| python manage.py dbshell
