import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final VoidCallback? onSendImage;
  final VoidCallback? onSendFile;
  final Function(bool)? onTyping;

  const ChatInputWidget({
    Key? key,
    required this.controller,
    required this.onSendMessage,
    this.onSendImage,
    this.onSendFile,
    this.onTyping,
  }) : super(key: key);

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _isRecording = false;
  bool _isTyping = false;
  final AudioRecorder _recorder = AudioRecorder();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isTyping = widget.controller.text.trim().isNotEmpty;
    if (_isTyping != isTyping) {
      setState(() => _isTyping = isTyping);
      widget.onTyping?.call(isTyping);
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) return;

    try {
      setState(() => _isRecording = true);

      await _recorder.start(const RecordConfig(), path: 'temp_recording.m4a');
      // Recording started successfully
    } catch (error) {
      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        // TODO: Upload voice message and send
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice message functionality coming soon')),
        );
      }
    } catch (error) {
      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording')),
      );
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement camera functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Camera functionality coming soon')),
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSendImage?.call();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSendFile?.call();
                  },
                ),
              ],
            ),
            SizedBox(height: 4.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement location sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Location sharing coming soon')),
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.person,
                  label: 'Contact',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement contact sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contact sharing coming soon')),
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.poll,
                  label: 'Poll',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement poll creation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Poll functionality coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 6.w,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: Icon(
              Icons.attach_file,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),

          // Text input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 3.w),
                      ),
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),

                  // Emoji button
                  IconButton(
                    onPressed: () {
                      // TODO: Implement emoji picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Emoji picker coming soon')),
                      );
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 2.w),

          // Send/Voice button
          GestureDetector(
            onTap: _isTyping
                ? () => widget.onSendMessage(widget.controller.text)
                : null,
            onLongPressStart: !_isTyping ? (_) => _startRecording() : null,
            onLongPressEnd: !_isTyping ? (_) => _stopRecording() : null,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _isRecording
                    ? Colors.red
                    : AppTheme.lightTheme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTyping
                    ? Icons.send
                    : _isRecording
                        ? Icons.stop
                        : Icons.mic,
                color: Colors.white,
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}