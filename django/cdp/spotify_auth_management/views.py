from django.shortcuts import  redirect
from .credentials import REDIRECT_URI, CLIENT_SECRET, CLIENT_ID
from rest_framework.views import APIView
from requests import Request, post
from rest_framework import status
from rest_framework.response import Response
from .util import *
from django.views import generic

#from the front end we call this API end point then we redirect to the url, 
# the url takes the authorization and redirect to the spotify_callback function that
# will send the request for the token, store the token and redirect back to the original application

class AuthURL(APIView):
  def get(self, request, format=None):
    scopes = 'user-read-private user-top-read'

    url = Request('GET', 'https://accounts.spotify.com/authorize', params={
      'scope': scopes,
      'response_type': 'code', 
      'redirect_uri': REDIRECT_URI,
      'client_id': CLIENT_ID
    }).prepare().url 

    return Response({'url': url}, status=status.HTTP_200_OK)


class index(generic.TemplateView):
  template_name = 'login.html'
  # return HttpResponse("You have logged in correctly!")


def spotify_callback(request, format=None):
  code = request.GET.get('code') #code we will use to authenticate the user
  error = request.GET.get('error') #error message if there is any

  #to get access token and refresh token
  response = post('https://accounts.spotify.com/api/token', data={
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': REDIRECT_URI,
      'client_id': CLIENT_ID,
      'client_secret': CLIENT_SECRET
  }).json() #with post we send the request and automatically get the response in json format

  print(response)
  access_token = response.get('access_token')
  token_type = response.get('token_type')
  refresh_token = response.get('refresh_token')
  expires_in = response.get('expires_in')
  error = response.get('error')

  if not request.session.exists(request.session.session_key):
    request.session.create()

  #we create a sort of database of the user authenticated with the token and the key
  update_or_create_user_tokens(request.session.session_key, access_token, token_type, expires_in, refresh_token)

  print('callback finished')

  return  redirect('index') #to redirect to the index page inside our project


# call s_spotify_authenticated and return a json response
class IsAuthenticated(APIView):
  def get(self, request, format=None):
    is_authenticated = is_spotify_authenticated(self.request.session.session_key)
    if not is_authenticated:
      return redirect('get-auth-url')
    return Response({'status': is_authenticated}, status=status.HTTP_200_OK)


class TopTrack(APIView):
  def get(self, request, format=None):
    endpointTopTrack = "me/top/tracks?time_range=short_term&limit=1"
    response = execute_spotify_api_request(request.session.session_key,endpoint=endpointTopTrack)
    artist = response["items"][0]["artists"][0]["name"]
    song = response["items"][0]["name"]
    uri = response["items"][0]["id"]

    endpointFeaturesByURI = "audio-features/{}".format(uri)
    response = execute_spotify_api_request(request.session.session_key,endpoint=endpointFeaturesByURI)

    acousticness = response["acousticness"]
    valence = response["valence"]
    energy = response["energy"]
    speechiness = response["speechiness"]
    tempo = response["tempo"]
    danceability = response["danceability"]
    mode = response["mode"]
    values = {'Acousticness': acousticness, 'Valence': valence, 'Energy': energy, 'Speechiness': speechiness, 'Tempo': tempo, 'Danceability': danceability, 'Mode': mode}
    print(values)
    send_msg(request=request, acousticness=acousticness, valence=valence, energy=energy, speechiness=speechiness, tempo=tempo, danceability=danceability, mode=mode)
    return Response({'status': values}, status=status.HTTP_200_OK)
