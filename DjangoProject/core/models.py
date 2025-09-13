from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.core.exceptions import ValidationError
from django.conf import settings

def validate_school_email(value):
    if not value.endswith("@ictuniversity.edu.cm"):   # school domain
        raise ValidationError("You must use your ictu email to register.")


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(email, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(unique=True, validators=[validate_school_email])
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    profile_picture = models.URLField(blank=True, null=True)

    objects = UserManager()
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def _str_(self):
        return self.email

class RiskArea(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    latitude = models.CharField(max_length=255)
    longitude = models.CharField(max_length=255)
    radius = models.FloatField(help_text="Radius in meters for risk area")

    def __str__(self):
        return self.name


class Alert(models.Model):
    ALERT_TYPE_CHOICES = [
        ('SOS', 'SOS')
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    alert_type = models.CharField(max_length=20, choices=ALERT_TYPE_CHOICES)
    timestamp = models.DateTimeField(auto_now_add=True)
    risk_area = models.ForeignKey(RiskArea, on_delete=models.SET_NULL, null=True, blank=True)
    location_link = models.URLField(blank=True, null=True)
    audio = models.FileField(upload_to='alert_audios/', blank=True, null=True)

    def credibility_score(self):
        total = self.alertvalidation_set.count()
        if total == 0:
            return 0
        true_count = self.alertvalidation_set.filter(is_true=True).count()
        return (true_count / total) * 100  # returns percentage

class TrustScore(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='trust_score')
    score = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.user.email} - Trust Score: {self.score}"


class AlertValidation(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    alert = models.ForeignKey('Alert', on_delete=models.CASCADE)
    is_true = models.BooleanField()  # True if the alert was actually true
    validated_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'alert')

    def __str__(self):
        return f"{self.user.email} validated {self.alert} as {'True' if self.is_true else 'False'}"

    def save(self, *args, **kwargs):
        is_new = self._state.adding

class Endorsement(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    alert = models.ForeignKey('Alert', on_delete=models.CASCADE, related_name='endorsements')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'alert')





