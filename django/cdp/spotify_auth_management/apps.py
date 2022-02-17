from django.apps import AppConfig
from .models import MessageValues
from django.http import JsonResponse

class SpotifyAuthManagementConfig(AppConfig):
    #default_auto_field = 'django.db.models.BigAutoField'
    name = 'spotify_auth_management'

    def get_msgs(request):
        spotifyValues=MessageValues.objects.all()
        response={"values":[]}
        for value in spotifyValues:
            response["values"].append(value.text)
        return JsonResponse(response)
