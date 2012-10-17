DUMP = techsup_run/fixtures/initial_data.json

clear :
	python manage.py sqlclear techsup_run | python manage.py dbshell

clean_fill : clear
	test -e $(DUMP) && rm $(DUMP) || echo
	python manage.py syncdb
	python manage.py techsup_fill_primaries
	cat common_data/generating/equipment.sql | python manage.py dbshell
	cat common_data/generating/detail.sql    | python manage.py dbshell
	python manage.py techsup_dump > $(DUMP)

fill : clear
	python manage.py syncdb

