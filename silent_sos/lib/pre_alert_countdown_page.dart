import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles.dart';
import '../utils.dart';

class PreAlertCountdownPage extends StatefulWidget {
  final String? userEmail;
  final VoidCallback? onCancel;
  final VoidCallback? onFinished;

  const PreAlertCountdownPage({
    super.key,
    this.userEmail,
    this.onCancel,
    this.onFinished,
  });

  @override
  State<PreAlertCountdownPage> createState() => _PreAlertCountdownPageState();
}

class _PreAlertCountdownPageState extends State<PreAlertCountdownPage>
    with TickerProviderStateMixin {
  static const int totalSeconds = 5;
  late Timer _timer;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  int remaining = totalSeconds;
  bool _isTriggering = false;
  bool _alertSent = false;
  bool _permissionsChecked = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _requestPermissionsAndStart();
  }

  void _setupAnimations() {
    // Smooth circular progress animation
    _progressController = AnimationController(
      duration: Duration(seconds: totalSeconds),
      vsync: this,
    );

    // Pulse animation for urgency
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Smooth progress animation from 0 to 1
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.linear, // Linear for consistent speed
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  Future<void> _requestPermissionsAndStart() async {
    print('Requesting permissions before countdown...');

    // Request location permission
    bool locationGranted = await AlertUtils.requestLocationPermission();
    if (!locationGranted) {
      _showPermissionDeniedDialog(
        'Location',
        'We need location access to send your emergency location.',
      );
      return;
    }

    // Request audio permission
    bool audioGranted = await AlertUtils.requestAudioPermission();
    if (!audioGranted) {
      _showPermissionDeniedDialog(
        'Microphone',
        'We need microphone access to record emergency audio.',
      );
      return;
    }

    setState(() {
      _permissionsChecked = true;
    });

    print('Permissions granted, starting countdown...');
    _startCountdown();
  }

  void _showPermissionDeniedDialog(String permission, String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAlert();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermissionsAndStart();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _startCountdown() {
    // Start progress animation
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining <= 1) {
        timer.cancel();
        setState(() {
          remaining = 0;
        });
        _triggerAlert();
      } else {
        setState(() {
          remaining--;
        });
        // Haptic feedback for each second
        HapticFeedback.lightImpact();
      }
    });
  }

  Future<void> _triggerAlert() async {
    if (_isTriggering || _alertSent) return;

    setState(() {
      _isTriggering = true;
    });

    // Stop pulse animation and show loading
    _pulseController.stop();

    // Strong haptic feedback for alert trigger
    HapticFeedback.heavyImpact();

    try {
      // Show immediate feedback
      _showLoadingSnackBar();

      print('Countdown completed, triggering SOS alert...');

      // Trigger the SOS alert
      bool success = await AlertUtils.triggerSosAlert(
        userEmail: widget.userEmail,
      );

      if (success) {
        setState(() {
          _alertSent = true;
        });

        // Show success feedback for 5 seconds
        _showSuccessSnackBar();

        // Wait for snackbar duration then exit automatically
        await Future.delayed(const Duration(seconds: 5));

        widget.onFinished?.call();

        // Ensure we exit automatically
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
                (route) => false,
          );
        }
      } else {
        // Show error and allow retry
        _showErrorSnackBar();
        setState(() {
          _isTriggering = false;
        });
      }
    } catch (e) {
      print('Error triggering alert: $e');
      _showErrorSnackBar();
      setState(() {
        _isTriggering = false;
      });
    }
  }


  void _cancelAlert() {
    HapticFeedback.mediumImpact();
    _timer.cancel();
    _progressController.stop();
    _pulseController.stop();

    widget.onCancel?.call();
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  void _showLoadingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Triggering SOS alert...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 10),
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'SOS alert sent successfully! Emergency services have been notified.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5), // Changed to 5 seconds
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to send SOS alert. Please check your connection and try again.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.danger,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _triggerAlert,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Show loading screen while checking permissions
    if (!_permissionsChecked && !_isTriggering) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              SizedBox(height: 20),
              Text(
                'Requesting permissions...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              // Header with urgency indicator
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Icon(
                            Icons.warning,
                            size: 48,
                            color: AppColors.danger,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    Text(
                      'EMERGENCY ALERT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              // Main countdown area with smooth circular progress
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: screenWidth * 0.6,
                          height: screenWidth * 0.6,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Circular progress indicator
                              SizedBox(
                                width: screenWidth * 0.6,
                                height: screenWidth * 0.6,
                                child: AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return CircularProgressIndicator(
                                      value: _progressAnimation.value,
                                      strokeWidth: 12,
                                      backgroundColor: AppColors.muted,
                                      valueColor: AlwaysStoppedAnimation(
                                        _isTriggering ? AppColors.primary : AppColors.danger,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Countdown number
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.bg,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: _isTriggering
                                    ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Sending...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.bg,
                                      ),
                                    ),
                                  ],
                                )
                                    : Text(
                                  remaining.toString(),
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Description text
              Expanded(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Text(
                      _isTriggering
                          ? 'Sending your emergency alert...'
                          : _alertSent
                          ? 'Alert sent successfully!'
                          : 'Emergency alert will be sent in $remaining seconds.\nTap CANCEL to abort.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),

              // Cancel button - only show if not triggered yet
              if (!_isTriggering && !_alertSent)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _cancelAlert,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'CANCEL ALERT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
