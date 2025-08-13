import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class VoiceVideoCall extends StatefulWidget {
  const VoiceVideoCall({Key? key}) : super(key: key);

  @override
  State<VoiceVideoCall> createState() => _VoiceVideoCallState();
}

class _VoiceVideoCallState extends State<VoiceVideoCall>
    with TickerProviderStateMixin {
  // Mock call data
  final Map<String, dynamic> currentCall = {
    "id": "call_001",
    "contactName": "Sarah Johnson",
    "contactAvatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face",
    "isVideoCall": true,
    "isIncoming": false,
    "startTime": DateTime.now().subtract(Duration(minutes: 2, seconds: 15)),
    "connectionQuality": "excellent", // excellent, good, poor
    "isGroupCall": false,
    "participants": [
      {
        "id": "user_001",
        "name": "Sarah Johnson",
        "avatar":
            "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face",
        "isMuted": false,
        "hasVideo": true,
        "isActive": true
      }
    ]
  };

  // Call state variables
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;
  bool _controlsVisible = true;
  bool _isCallActive = true;
  Timer? _callTimer;
  Timer? _hideControlsTimer;
  Duration _callDuration = Duration.zero;

  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isFrontCamera = true;
  bool _cameraInitialized = false;

  // Audio recording variables
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCall();
    _startCallTimer();
    _startHideControlsTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _fadeController.forward();
  }

  Future<void> _initializeCall() async {
    if (currentCall["isVideoCall"] as bool) {
      await _initializeCamera();
    }
    await _requestMicrophonePermission();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _requestMicrophonePermission() async {
    if (kIsWeb) {
      return;
    }
    final status = await Permission.microphone.request();
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.off);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _isCallActive) {
        setState(() {
          _callDuration = DateTime.now().difference(currentCall["startTime"]);
        });
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 5), () {
      if (mounted && _isCallActive) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _showControls() {
    setState(() {
      _controlsVisible = true;
    });
    _startHideControlsTimer();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _showControls();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    _showControls();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    _showControls();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  Future<void> _switchCamera() async {
    if (_cameraController == null || _cameras.length < 2) return;

    try {
      await _cameraController!.dispose();

      final camera = _isFrontCamera
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });

      _showControls();
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  void _endCall() {
    // Haptic feedback
    HapticFeedback.heavyImpact();

    setState(() {
      _isCallActive = false;
    });

    // Navigate back after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Color _getConnectionQualityColor() {
    switch (currentCall["connectionQuality"]) {
      case "excellent":
        return AppTheme.lightTheme.colorScheme.tertiary;
      case "good":
        return AppTheme.lightTheme.colorScheme.primary;
      case "poor":
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _hideControlsTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    _cameraController?.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _showControls,
        child: SafeArea(
          child: Stack(
            children: [
              // Background/Video Feed
              _buildVideoBackground(),

              // Call Information Overlay
              if (_controlsVisible) _buildCallInfoOverlay(),

              // Call Controls
              if (_controlsVisible) _buildCallControls(),

              // Connection Quality Indicator
              _buildConnectionQualityIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBackground() {
    final isVideoCall = currentCall["isVideoCall"] as bool;

    if (isVideoCall &&
        _isVideoEnabled &&
        _cameraInitialized &&
        _cameraController != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Remote video (simulated with contact avatar)
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomImageWidget(
                imageUrl: currentCall["contactAvatar"],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Self video (picture-in-picture)
            Positioned(
              top: 2.h,
              right: 4.w,
              child: GestureDetector(
                onPanUpdate: (details) {
                  // Handle dragging of self-view
                },
                child: Container(
                  width: 25.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),

            // Camera switch button
            Positioned(
              top: 2.h,
              right: 30.w,
              child: GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'flip_camera_ios',
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Voice call or video disabled - show contact avatar
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: currentCall["contactAvatar"],
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.h),
              Text(
                currentCall["contactName"],
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                isVideoCall ? "Video Call" : "Voice Call",
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCallInfoOverlay() {
    return Positioned(
      top: 2.h,
      left: 4.w,
      right: 4.w,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Call duration
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(_callDuration),
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Additional options
            GestureDetector(
              onTap: () {
                // Show more options
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'more_vert',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Positioned(
      bottom: 8.h,
      left: 4.w,
      right: 4.w,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Primary controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                _buildControlButton(
                  icon: _isMuted ? 'mic_off' : 'mic',
                  isActive: _isMuted,
                  onTap: _toggleMute,
                  backgroundColor: _isMuted
                      ? AppTheme.lightTheme.colorScheme.error
                      : Colors.white.withValues(alpha: 0.2),
                ),

                // Video toggle (only for video calls)
                if (currentCall["isVideoCall"] as bool)
                  _buildControlButton(
                    icon: _isVideoEnabled ? 'videocam' : 'videocam_off',
                    isActive: !_isVideoEnabled,
                    onTap: _toggleVideo,
                    backgroundColor: !_isVideoEnabled
                        ? AppTheme.lightTheme.colorScheme.error
                        : Colors.white.withValues(alpha: 0.2),
                  ),

                // Speaker button
                _buildControlButton(
                  icon: _isSpeakerOn ? 'volume_up' : 'volume_down',
                  isActive: _isSpeakerOn,
                  onTap: _toggleSpeaker,
                  backgroundColor: _isSpeakerOn
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.white.withValues(alpha: 0.2),
                ),

                // End call button
                _buildControlButton(
                  icon: 'call_end',
                  isActive: false,
                  onTap: _endCall,
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  size: 16.w,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Secondary controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Add participant
                _buildSecondaryControlButton(
                  icon: 'person_add',
                  label: 'Add',
                  onTap: () {
                    // Navigate to contact selection
                  },
                ),

                // Screen share (video calls only)
                if (currentCall["isVideoCall"] as bool)
                  _buildSecondaryControlButton(
                    icon:
                        _isScreenSharing ? 'stop_screen_share' : 'screen_share',
                    label: _isScreenSharing ? 'Stop' : 'Share',
                    onTap: () {
                      setState(() {
                        _isScreenSharing = !_isScreenSharing;
                      });
                    },
                  ),

                // Chat
                _buildSecondaryControlButton(
                  icon: 'chat',
                  label: 'Chat',
                  onTap: () {
                    Navigator.pushNamed(context, '/chat-detail');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color backgroundColor,
    double? size,
  }) {
    final buttonSize = size ?? 14.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: buttonSize * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryControlButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: Colors.white,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionQualityIndicator() {
    return Positioned(
      top: 8.h,
      left: 4.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: _getConnectionQualityColor(),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              currentCall["connectionQuality"].toString().toUpperCase(),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
