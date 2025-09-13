import json

from allauth.account.internal.flows.logout import logout
from allauth.core.internal.httpkit import redirect
from allauth.socialaccount.models import SocialAccount, SocialToken
from asgiref.sync import async_to_sync
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from google.auth.transport import requests, Response
from google.oauth2 import id_token
from rest_framework import generics, status, viewsets, permissions
from rest_framework.exceptions import ValidationError
from django.http import JsonResponse
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from channels.layers import get_channel_layer

from .models import User, RiskArea, Alert, validate_school_email, Endorsement
from .serializers import UserSerializer, RiskAreaSerializer, AlertSerializer, LoginSerializer, EndorsementSerializer

#class GoogleAuthView(APIView):
#   def post(self, request):
#       token = request.data.get('token')
#       try:
#           idinfo = id_token.verify_oauth2_token(token, requests.Request())
#           email = idinfo.get('email')
#           picture = idinfo.get('picture')
#           # Validate school email
#           try:
#               validate_school_email(email)
 #           except ValidationError as e:
#              return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
#           # Get or create user
#           user, created = User.objects.get_or_create(email=email)
#           # Save profile picture if you have a field for it
#           if picture and hasattr(user, 'profile_picture'):
#               user.profile_picture = picture
#               user.save()
#           # Return success
#           return Response({'message': 'Authenticated', 'user': email}, status=status.HTTP_200_OK)
 #       except ValueError:
#          return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

def google_login_callback(request):
    user = request.user
    social_accounts = SocialAccount.objects.filter(user=user, provider='google')
    social_account = social_accounts.first()


    if not social_account:
        return JsonResponse({'error': 'NoSocialAccount'}, status=400)

    try:
        token = SocialToken.objects.get(account=social_account, account__provider='google')
    except SocialToken.DoesNotExist:
        return JsonResponse({'error': 'NoGoogleToken'}, status=400)

    refresh = RefreshToken.for_user(user)
    access_token = str(refresh.access_token)
    return JsonResponse({'access_token': access_token}, status=200)

@csrf_exempt
def validate_google_token(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            google_access_token = data.get('access_token')
            print(f'Google access token >>> {google_access_token}')

            if not google_access_token:
                return JsonResponse({'error': 'Access token is missing'}, status=400)
            return JsonResponse({'valid': True}, status=200)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    return JsonResponse({'error': 'Invalid request method'}, status=405)


def google_logout(request):
    user = request.user

    # Revoke the Google token
    social_tokens = SocialToken.objects.filter(account__user=user, account__provider='google')
    if social_tokens.exists():
        token = social_tokens.first()
        revoke_url = f'https://accounts.google.com/o/oauth2/revoke?token={token.token}'
        response = requests.post(revoke_url)
        if response.status_code == 200:
            print('Google token successfully revoked.')
        else:
            print(f'Failed to revoke Google token: {response.status_code}')

        # Delete the token from the database
        social_tokens.delete()

    # Log the user out of the Django application
    logout(request)

    # Clear the session
    request.session.flush()

    # Send a response to the frontend and redirect to the login page
    return JsonResponse({'message': 'User logged out successfully'}, status=200)


class EndorsementViewSet(viewsets.ModelViewSet):
    queryset = Endorsement.objects.all()
    serializer_class = EndorsementSerializer
    permission_classes = [permissions.IsAuthenticated]


#login view to get JWT tokens
class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            user, created = User.objects.get_or_create(email=email)
            refresh = RefreshToken.for_user(user)
            return JsonResponse({
                "user": {
                    "id": user.id,
                    "email": user.email
                },
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            }, status=status.HTTP_200_OK)
        return JsonResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class RiskAreaViewSet(viewsets.ModelViewSet):
    queryset = RiskArea.objects.all()
    serializer_class = RiskAreaSerializer
    permission_classes = [IsAuthenticated]

class AlertViewSet(viewsets.ModelViewSet):
    queryset = Alert.objects.all()
    serializer_class = AlertSerializer
    permission_classes = [AllowAny]


    def perform_create(self, serializer):
        alert = serializer.save(user=self.request.user)
        # Broadcast alert to relevant users/groups
        channel_layer = get_channel_layer()
        # Example: send to all users (replace with your logic for nearby users)
        async_to_sync(channel_layer.group_send)(
            "alerts",
            {
                "type": "send_alert",
                "alert": {
                    "id": alert.id,
                    "user": alert.user.email,
                    "timestamp": str(alert.timestamp),
                    "location_link": alert.location_link,
                }
            }
        )

    # def get_queryset(self):
    #     #return only alerts of the logged-in user
    #     return Alert.objects.filter(user=self.request.user)
# Create your views here.
