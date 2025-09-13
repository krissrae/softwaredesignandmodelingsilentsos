from django.contrib import admin
from .models import Alert, Endorsement, RiskArea, User, TrustScore, AlertValidation

# Register your models here.

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'is_active', 'is_staff', 'profile_picture')
    list_filter = ('is_active', 'is_staff')
    search_fields = ('email',)
    readonly_fields = ('last_login',)

@admin.register(RiskArea)
class RiskAreaAdmin(admin.ModelAdmin):
    list_display = ('name', 'latitude', 'longitude', 'radius')
    search_fields = ('name', 'description')
    list_filter = ('radius',)

@admin.register(Alert)
class AlertAdmin(admin.ModelAdmin):
    list_display = ('user', 'alert_type', 'timestamp', 'risk_area', 'credibility_score')
    list_filter = ('alert_type', 'timestamp', 'risk_area')
    search_fields = ('user__email',)
    readonly_fields = ('timestamp', 'credibility_score')

@admin.register(TrustScore)
class TrustScoreAdmin(admin.ModelAdmin):
    list_display = ('user', 'score')
    search_fields = ('user__email',)
    list_filter = ('score',)

@admin.register(AlertValidation)
class AlertValidationAdmin(admin.ModelAdmin):
    list_display = ('user', 'alert', 'is_true', 'validated_at')
    list_filter = ('is_true', 'validated_at')
    search_fields = ('user__email', 'alert__user__email')
    readonly_fields = ('validated_at',)

@admin.register(Endorsement)
class EndorsementAdmin(admin.ModelAdmin):
    list_display = ('user', 'alert', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('user__email', 'alert__user__email')
    readonly_fields = ('created_at',)