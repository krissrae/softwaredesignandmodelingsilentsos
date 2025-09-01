from rest_framework import serializers
from .models import User,RiskArea, Alert

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'is_active', 'is_staff']

class RiskAreaSerializer(serializers.ModelSerializer):
    class Meta:
        model = RiskArea
        fields = '__all__'

class AlertSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    risk_area = RiskAreaSerializer(read_only=True)

    class Meta:
        model = Alert
        fields = '__all__'

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate(self, value):
        if not value.endswith("@ictuniversity.edu.cm"):
            raise serializers.ValidationError("You must use your ictu email to register.")
        return value
