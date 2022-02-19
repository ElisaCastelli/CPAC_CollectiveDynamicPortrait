from django.db import models

class SpotifyToken(models.Model):
    user = models.CharField(max_length=64, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    refresh_token = models.CharField(max_length=512, null=True, blank=True) 
    access_token = models.CharField(max_length=512)
    expires_in = models.DateTimeField()
    token_type = models.CharField(max_length=64)


class MessageValues(models.Model):
    acousticness = models.FloatField()
    valence = models.FloatField()
    energy = models.FloatField()
    speechiness = models.FloatField()
    tempo = models.FloatField()
    danceability = models.FloatField()
    mode = models.FloatField()
