# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-02-13 21:21
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dwtn', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='location',
            name='details',
            field=models.CharField(default='text', max_length=500),
            preserve_default=False,
        ),
    ]
