from operator import is_
from django.http import HttpResponse
from django.shortcuts import render, redirect
from .credentials import REDIRECT_URI, CLIENT_SECRET, CLIENT_ID
from rest_framework.views import APIView
from requests import Request, post
from rest_framework import status
from rest_framework.response import Response
from .util import is_spotify_authenticated, update_or_create_user_tokens
from django.views import generic


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
  code = request.GET.get('code')
  error = request.GET.get('error')

  response = post('https://accounts.spotify.com/api/token', data={
    'grant_type': 'authorization_code',
    'response_type': code,
    'redirect_uri': REDIRECT_URI,
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET
  }).json()

  access_token = response.get('access_token')
  token_type = response.get('token_type')
  refresh_token = response.get('refresh_token')
  expires_in = response.get('expires_in')
  error = response.get('error')

  if not request.session.exists(request.session.session_key):
    request.session.create()

  update_or_create_user_tokens(request.session.session_key, access_token, token_type, expires_in, refresh_token)

  print('callback finished')

  return redirect('cdp:index')

class IsAuthenticated(APIView):
  def get(self, request, format=None):
    is_authenticated = is_spotify_authenticated(self.request.session.session_key)
    if not is_authenticated:
      return redirect('get-auth-url')
    return Response({'status': is_authenticated}, status=status.HTTP_200_OK)
