# Generated by Django 4.0.1 on 2022-02-17 18:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('spotify_auth_management', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='MessageValues',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('acousticness', models.FloatField()),
                ('valence', models.FloatField()),
                ('energy', models.FloatField()),
                ('speechiness', models.FloatField()),
                ('tempo', models.FloatField()),
                ('danceability', models.FloatField()),
                ('mode', models.FloatField()),
            ],
        ),
    ]
