from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse
from django.core import serializers
import json

from .models import Category, Location

def index(request):
    category_list = Category.objects.all()
    context = {'category_list':category_list}
    return render(request, 'dwtn/index.html', context)
    
def detail(request, category_id):
    category = get_object_or_404(Category, pk=category_id)
    return render(request, 'dwtn/detail.html', {'category':category})
    
def location(request, location_name):
    location = get_object_or_404(Location, pk=location_id)
    return render(request, 'dwtn/location.html', {'location':location})

def make_json(request):
    #locations = Location.objects.all()
    #data = serializers.serialize('json', locations[fields])
    list = []
    

    for category in Category.objects.all():
        list.append({"category": category.category_name})
    for location in Location.objects.all():
        list.append({"name": location.location_name, "lon": str(location.lon), "lat": str(location.lat), "img": location.image, "details": location.details, "state": location.state, "catid":location.category})
    data = json.dumps(list)
    
    return HttpResponse(data) #, content_type='application/json')
    
    '''for category in Category.objects.all():
        if location.category == category.id:'''
            
    '''for location in Location.objects.all():
        qs = location.to_dict()
    data = serializers.serialize("json", qs)

    #my_dict = locations.__dict__
    #data = model_to_dict(locations)
            
    return HttpResponse(qs, content_type='application/json')'''
    
    '''for location in Location.objects.all():
        my_dict = location.__dict__
        
    #data = serializers.serialize('json', locations)
    return HttpResponse(my_dict)#, content_type='application/json') '''
    
    
    
    

