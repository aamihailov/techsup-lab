from django.conf.urls import patterns, url

urlpatterns = patterns('',
    url(r'^(\d+)/$', 'techsup_run.views.home', name='home'),
    url(r'^(\d+)-(\d+)/$', 'techsup_run.views.many', name='home'),
)
