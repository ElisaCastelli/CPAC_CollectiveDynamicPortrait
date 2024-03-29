from pickle import TRUE
from .models import SpotifyToken, MessageValues
from django.utils import timezone
from django.http import JsonResponse
from datetime import timedelta
from .credentials import CLIENT_ID, CLIENT_SECRET
from requests import post, put, get

BASE_URL = "https://api.spotify.com/v1/"

def get_user_tokens(session_id):
    user_tokens = SpotifyToken.objects.filter(user=session_id)
    if user_tokens.exists():
        print("Scadenza già esistente: ",user_tokens[0].expires_in)
        return user_tokens[0]
    else:
        return None


# function to check if the time is over
def is_spotify_authenticated(session_id): 
    tokens = get_user_tokens(session_id)
    if tokens:
        expiry = tokens.expires_in
        if expiry <= timezone.now():
            print("Scaduto")
            refresh_spotify_token(session_id)
        
        return True

    return False

# function to refresh the token when time is expired
def refresh_spotify_token(session_id): 
    refresh_token = get_user_tokens(session_id).refresh_token
    
    response = post('https://accounts.spotify.com/api/token', data={
        'grant_type': 'refresh_token',
        'refresh_token': refresh_token,
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET
    }).json()

    access_token = response.get('access_token')
    token_type = response.get('token_type')
    expires_in = response.get('expires_in')
    #refresh_token = response.get('refresh_token')
    #REFRESH è stato tolto perchè nella response era None ma nel db c'è la constraint che non può essere nullo
    #non so come togliere la constraint, quindi ho rimesso quello vecchio

    update_or_create_user_tokens(session_id, access_token, token_type, expires_in, refresh_token)

    # function to create or refresh user token
def update_or_create_user_tokens(session_id, access_token, token_type, expires_in, refresh_token):
    tokens = get_user_tokens(session_id)
    print("Update:",tokens)
    expires_in = timezone.now() + timedelta(seconds=expires_in)
    print("Scadenza:",expires_in)

    if tokens:
        tokens.access_token = access_token
        tokens.refresh_token = refresh_token
        tokens.expires_in = expires_in
        tokens.token_type = token_type
        tokens.save(update_fields=['access_token', 'refresh_token', 'expires_in', 'token_type'])
    else:
        tokens = SpotifyToken(user=session_id, access_token=access_token, refresh_token=refresh_token, token_type=token_type, expires_in=expires_in)
        tokens.save()

def execute_spotify_api_request(session_id, endpoint, post_=False, put_=False):
    tokens = get_user_tokens(session_id)
    header = {  'Accept': "application/json",
                'Content-Type': 'application/json', 
                'Authorization': "Bearer " + tokens.access_token }

    if post_:
        post(BASE_URL + endpoint, headers=header)
    if put_:
        put(BASE_URL + endpoint, headers=header)

    response = get(BASE_URL + endpoint, {}, headers=header)
    try:
        return response.json()
    except:
        return {'Error': 'Issue with request'}

def send_msg(request, title, artist, acousticness, valence, energy, speechiness, tempo, danceability, mode):
    try:
        obj=MessageValues.objects.create(title = title, artist = artist, acousticness=acousticness, valence=valence, 
            energy=energy, speechiness=speechiness, tempo=tempo, danceability=danceability, mode=mode)
        obj.save()
        response={"status":"ok", "message":"ok" }
    except Exception as exc:
        response={"status":"fail", "message":str(exc)}
    return JsonResponse(response)

def get_msgs(request):
        spotifyValues = MessageValues.objects.all()
        #spotifyValues = MessageValues.objects.last()
        response = {}

        print('RESPONSE: ', response)
        for value in spotifyValues:
            response["title"] = value.title
            response["artist"] = value.artist
            response["acousticness"] = value.acousticness
            response["valence"] = value.valence
            response["energy"] = value.energy
            response["speechiness"] = value.speechiness
            response["tempo"] = value.tempo
            response["danceability"] = value.danceability
            response["mode"] = value.mode
        return JsonResponse(response)

def deleteAllFromSpotifyValues():
    MessageValues.objects.all().delete()