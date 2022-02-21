from django.db import models

class SpotifyToken(models.Model):
    user = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    refresh_token = models.CharField(max_length=150)
    access_token = models.CharField(max_length=150)
    expires_in = models.DateTimeField()
    token_type = models.CharField(max_length=50)


class MessageValues(models.Model):
    title = models.CharField(max_length=128)
    artist = models.CharField(max_length=128)
    acousticness = models.FloatField()
    valence = models.FloatField()
    energy = models.FloatField()
    speechiness = models.FloatField()
    tempo = models.FloatField()
    danceability = models.FloatField()
    mode = models.FloatField()
