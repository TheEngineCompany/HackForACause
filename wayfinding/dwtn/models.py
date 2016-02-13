from __future__ import unicode_literals
from django.db import models

class Category(models.Model):
    #locations belong to categories
    category_name = models.CharField(max_length=200)

class Location(models.Model):
    location_name = models.CharField(max_length=200)
    lon = models.DecimalField(max_digits=10, decimal_places=7)      # excessive, eh?
    lat = models.DecimalField(max_digits=10, decimal_places=7)
    image = models.CharField(max_length=300)                        # possibly excessive too
    state = models.BooleanField()
    category = models.ForeignKey(Category, on_delete=models.CASCADE)    #what does the on_delete call do here?

    
