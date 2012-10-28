from django.conf.urls import patterns, url

urlpatterns = patterns('',
    url(r'^(\d+)/$', 'techsup_run.views.home', name='home'),
    url(r'^(\d+)-(\d+)/$', 'techsup_run.views.many', name='home'),
    url(r'^maybe_owners/([a-z]+-\d{3}-\d{4}-\d{2}-[a-z]+)/$', 'techsup_run.views.maybe_owners', name='home'),
)
