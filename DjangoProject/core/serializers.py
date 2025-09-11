from rest_framework import serializers
from .models import User, RiskArea, Alert, Endorsement


class UserSerializer(serializers.ModelSerializer):
    trust_score = serializers.IntegerField(source='trust_score.score', read_only=True)
    class Meta:
        model = User
        fields = ['id', 'email', 'is_active', 'is_staff','trust_score','profile_picture']

class RiskAreaSerializer(serializers.ModelSerializer):
    class Meta:
        model = RiskArea
        fields = '__all__'

class AlertSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    risk_area = RiskAreaSerializer(read_only=True)
    audio = serializers.FileField(required=False, allow_null=True)

    class Meta:
        model = Alert
        fields = '__all__'

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate(self, value):
        if not value.endswith("@ictuniversity.edu.cm"):
            raise serializers.ValidationError("You must use your ictu email to register.")
        return value

class EndorsementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Endorsement
        fields = ['id', 'user', 'alert', 'created_at']

