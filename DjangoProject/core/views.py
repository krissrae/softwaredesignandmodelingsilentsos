from asgiref.sync import async_to_sync
from google.auth.transport import requests
from google.oauth2 import id_token
from rest_framework import generics, status, viewsets, permissions
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from channels.layers import get_channel_layer

from .models import User, RiskArea, Alert, validate_school_email, Endorsement
from .serializers import UserSerializer, RiskAreaSerializer, AlertSerializer, LoginSerializer, EndorsementSerializer

class GoogleAuthView(APIView):
    def post(self, request):
        token = request.data.get('token')
        try:
            idinfo = id_token.verify_oauth2_token(token, requests.Request())
            email = idinfo.get('email')
            picture = idinfo.get('picture')
            # Validate school email
            try:
                validate_school_email(email)
            except ValidationError as e:
                return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
            # Get or create user
            user, created = User.objects.get_or_create(email=email)
            # Save profile picture if you have a field for it
            if picture and hasattr(user, 'profile_picture'):
                user.profile_picture = picture
                user.save()
            # Return success
            return Response({'message': 'Authenticated', 'user': email}, status=status.HTTP_200_OK)
        except ValueError:
            return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

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
            return Response({
                "user": {
                    "id": user.id,
                    "email": user.email
                },
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class RiskAreaViewSet(viewsets.ModelViewSet):
    queryset = RiskArea.objects.all()
    serializer_class = RiskAreaSerializer
    permission_classes = [IsAuthenticated]

class AlertViewSet(viewsets.ModelViewSet):
    queryset = Alert.objects.all()
    serializer_class = AlertSerializer
    permission_classes = [IsAuthenticated]


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

    def get_queryset(self):
        #return only alerts of the logged-in user
        return Alert.objects.filter(user=self.request.user)
# Create your views here.
