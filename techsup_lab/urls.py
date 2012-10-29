from django.conf.urls import patterns, url

urlpatterns = patterns('',
    url(r'^$', 'techsup_run.views.test', name='test'),
    url(r'^list/employee/(\d+)/$', 'techsup_run.views.home', name='home'),
    url(r'^list/employee/(\d+)-(\d+)/$', 'techsup_run.views.many', name='home'),
    url(r'^list/equipment/$', 'techsup_run.views.equipment_list', name='task'),
    url(r'^maybe_owners/([a-z]+-\d{3}-\d{4}-\d{2}-[a-z]+)/$', 'techsup_run.views.maybe_owners', name='maybe_owners'),
    url(r'^owners/([a-z]+-\d{3}-\d{4}-\d{2}-[a-z]+)/(\d{3}-\d{3}-\d{3} \d{2})/$', 'techsup_run.views.owners', name='owners'),
    url(r'^task/([a-z]+-\d{3}-\d{4}-\d{2}-[a-z]+)/$', 'techsup_run.views.task', name='task'),
)
