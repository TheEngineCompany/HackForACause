from django.shortcuts import render
from django.http import HttpResponse


def index(self):
    return HttpResponse("Default text in index!")
    
def detail(request, category_id):
    response = "This is the detail view for category %s."
    return HttpResponse(response % category_id)
    
def result(request, category_id):
    return HttpResponse("This is the result for category %s" % category_id)
    
def vote(request, category_id):
    return HttpResponse("This is the vote page for category %s" % category_id)
    

