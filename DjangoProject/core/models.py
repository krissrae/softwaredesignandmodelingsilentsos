from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.core.exceptions import ValidationError

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

    objects = UserManager()
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def _str_(self):
        return self.email

class RiskArea(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    radius = models.FloatField(help_text="Radius in meters for risk area")

    def __str__(self):
        return self.name


class Alert(models.Model):
    ALERT_TYPES = (
        ('SOS', 'SOS'),
        ('RISK','Risk Area'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    alert_type = models.CharField(max_length=10, choices=ALERT_TYPES)
    timestamp = models.DateTimeField(auto_now_add=True)
    risk_area = models.ForeignKey(RiskArea, on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return f"{self.alert_type}@{self.timestamp}"
# Create your models here.
