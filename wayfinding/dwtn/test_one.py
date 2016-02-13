from django.core import serializers
from .models import Category, Location

def make_json(request):
    locations = Location.objects.all()
    data = serializers.serialize('json', locations)
    return HttpResponse(data, content_type='application/json')



