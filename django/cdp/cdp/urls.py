"""cdp URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from argparse import Namespace
from django.urls import include, path
from spotify_auth_management.views import *
from spotify_auth_management import util

app_name = 'cdp'

urlpatterns = [
    path('', index.as_view(), name='index'),
    path('get-auth-url', AuthURL.as_view(), name='get-auth-url'),
    path('redirect', spotify_callback),
    path('is-authenticated', IsAuthenticated.as_view()),
    path('top-track', TopTrack.as_view()),
    path('get_msgs', util.get_msgs, name="get_msgs")
]
