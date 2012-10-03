from django.core.management.base import BaseCommand
from techsup_run.models import all_models

class Command(BaseCommand):
    help = 'Deleting all data from database'

    def handle(self, *args, **options):
        for model in all_models:
            try:
                model.objects.all().delete()
                self.stdout.write('Clearing : ' + model.__name__ + '...', ending = ' ')
            except Exception, e:
                self.stdout.write('fail')
                self.stdout.write('\t%s' % e)
            else:
                self.stdout.write('pass')
