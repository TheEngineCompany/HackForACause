from django.conf.urls import url
from . import views

appname = 'dwtn'
urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^(?P<category_id>[0-9]+)/$', views.detail, name='detail'),
    url(r'^(?P<category_id>[0-9]+)/location/$', views.location, name='location'),
    url(r'^make_json/$', views.make_json),
]