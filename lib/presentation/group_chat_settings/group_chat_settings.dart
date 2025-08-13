import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/admin_controls_widget.dart';
import './widgets/group_header_widget.dart';
import './widgets/member_list_widget.dart';
import './widgets/settings_section_widget.dart';

class GroupChatSettings extends StatefulWidget {
  const GroupChatSettings({Key? key}) : super(key: key);

  @override
  State<GroupChatSettings> createState() => _GroupChatSettingsState();
}

class _GroupChatSettingsState extends State<GroupChatSettings> {
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  bool _hasUnsavedChanges = false;

  // Mock group data
  final Map<String, dynamic> _groupData = {
    "id": 1,
    "name": "Project Alpha Team",
    "description":
        "Collaborative workspace for Project Alpha development team. Share updates, files, and coordinate meetings here.",
    "photo":
        "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&h=400&fit=crop&crop=faces",
    "createdAt": "2025-01-15",
    "members": [
      {
        "id": 1,
        "name": "Sarah Johnson",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isAdmin": true,
        "isOnline": true,
        "lastSeen": "Online",
      },
      {
        "id": 2,
        "name": "Michael Chen",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isAdmin": false,
        "isOnline": true,
        "lastSeen": "Online",
      },
      {
        "id": 3,
        "name": "Emily Rodriguez",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isAdmin": false,
        "isOnline": false,
        "lastSeen": "Last seen 2 hours ago",
      },
      {
        "id": 4,
        "name": "David Kim",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isAdmin": true,
        "isOnline": false,
        "lastSeen": "Last seen yesterday",
      },
      {
        "id": 5,
        "name": "Lisa Thompson",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isAdmin": false,
        "isOnline": true,
        "lastSeen": "Online",
      },
    ],
  };

  // Current user (admin for demo)
  final Map<String, dynamic> _currentUser = {
    "id": 1,
    "name": "Sarah Johnson",
    "isAdmin": true,
  };

  // Group permissions
  Map<String, dynamic> _groupPermissions = {
    "canSendMessages": true,
    "canAddMembers": false,
    "canEditInfo": false,
    "canPinMessages": false,
    "requireApproval": true,
  };

  // Settings data
  List<Map<String, dynamic>> _notificationSettings = [];
  List<Map<String, dynamic>> _mediaSettings = [];
  List<Map<String, dynamic>> _privacySettings = [];
  List<Map<String, dynamic>> _destructiveActions = [];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _initializeCamera();
  }

  void _initializeCamera() {
    // Placeholder for camera initialization logic
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _initializeSettings() {
    _notificationSettings = [
      {
        "key": "notifications",
        "title": "Notifications",
        "subtitle": "Receive notifications for this group",
        "type": "switch",
        "value": true,
        "icon": "notifications",
      },
      {
        "key": "sound",
        "title": "Notification Sound",
        "type": "selection",
        "value": "Default",
        "options": ["Default", "Bell", "Chime", "Whistle", "None"],
        "icon": "volume_up",
      },
    ];

    _mediaSettings = [
      {
        "key": "auto_download",
        "title": "Auto-Download Media",
        "subtitle": "Automatically download photos and videos",
        "type": "switch",
        "value": true,
        "icon": "download",
      },
      {
        "key": "wallpaper",
        "title": "Chat Wallpaper",
        "type": "action",
        "icon": "wallpaper",
      },
    ];

    _privacySettings = [
      {
        "key": "read_receipts",
        "title": "Read Receipts",
        "subtitle": "Show when you've read messages",
        "type": "switch",
        "value": true,
        "icon": "done_all",
      },
      {
        "key": "typing_indicator",
        "title": "Typing Indicator",
        "subtitle": "Show when you're typing",
        "type": "switch",
        "value": true,
        "icon": "edit",
      },
    ];

    _destructiveActions = [
      {
        "key": "leave_group",
        "title": "Leave Group",
        "subtitle": "You will no longer receive messages from this group",
        "type": "action",
        "icon": "exit_to_app",
        "isDestructive": true,
      },
      if (_currentUser["isAdmin"] as bool)
        {
          "key": "delete_group",
          "title": "Delete Group",
          "subtitle": "Permanently delete this group for all members",
          "type": "action",
          "icon": "delete_forever",
          "isDestructive": true,
        },
    ];
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _showPhotoOptions() async {
    if (!(_currentUser["isAdmin"] as bool)) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 6.w,
              ),
              title: Text(
                'Remove Photo',
                style: TextStyle(color: AppTheme.errorLight),
              ),
              onTap: () {
                Navigator.pop(context);
                _removePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (!await _requestCameraPermission()) return;

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _groupData["photo"] = photo.path;
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _groupData["photo"] = image.path;
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image');
    }
  }

  void _removePhoto() {
    setState(() {
      _groupData["photo"] =
          "https://via.placeholder.com/400x400/E0E0E0/757575?text=Group";
      _hasUnsavedChanges = true;
    });
  }

  void _showEditGroupDialog() {
    if (!(_currentUser["isAdmin"] as bool)) return;

    final TextEditingController nameController =
        TextEditingController(text: _groupData["name"] as String);
    final TextEditingController descController =
        TextEditingController(text: _groupData["description"] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
              maxLength: 50,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter group description',
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _groupData["name"] = nameController.text.trim();
                _groupData["description"] = descController.text.trim();
                _hasUnsavedChanges = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onMemberTap(Map<String, dynamic> member) {
    Navigator.pushNamed(context, '/user-profile', arguments: member);
  }

  void _onMakeAdmin(Map<String, dynamic> member) {
    _showConfirmationDialog(
      'Make Admin',
      'Make ${member["name"]} an admin of this group?',
      () {
        setState(() {
          final memberIndex = (_groupData["members"] as List)
              .indexWhere((m) => m["id"] == member["id"]);
          if (memberIndex != -1) {
            (_groupData["members"] as List)[memberIndex]["isAdmin"] = true;
            _hasUnsavedChanges = true;
          }
        });
      },
    );
  }

  void _onRemoveMember(Map<String, dynamic> member) {
    _showConfirmationDialog(
      'Remove Member',
      'Remove ${member["name"]} from this group?',
      () {
        setState(() {
          (_groupData["members"] as List)
              .removeWhere((m) => m["id"] == member["id"]);
          _hasUnsavedChanges = true;
        });
      },
    );
  }

  void _onRestrictMember(Map<String, dynamic> member) {
    _showConfirmationDialog(
      'Restrict Member',
      'Restrict ${member["name"]}\'s permissions in this group?',
      () {
        // Implement restriction logic
        _showSuccessSnackBar('${member["name"]} has been restricted');
      },
    );
  }

  void _onSettingChanged(String key, dynamic value) {
    setState(() {
      // Update the appropriate settings list
      for (final settingsList in [
        _notificationSettings,
        _mediaSettings,
        _privacySettings,
        _destructiveActions
      ]) {
        final settingIndex = settingsList.indexWhere((s) => s["key"] == key);
        if (settingIndex != -1) {
          if (value != null) {
            settingsList[settingIndex]["value"] = value;
            _hasUnsavedChanges = true;
          } else {
            _handleActionSetting(key);
          }
          break;
        }
      }
    });
  }

  void _handleActionSetting(String key) {
    switch (key) {
      case 'wallpaper':
        _showWallpaperOptions();
        break;
      case 'leave_group':
        _leaveGroup();
        break;
      case 'delete_group':
        _deleteGroup();
        break;
    }
  }

  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'color_lens',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Solid Colors'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'image',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Custom Image'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'restore',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Reset to Default'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _onPermissionChanged(String key, dynamic value) {
    setState(() {
      _groupPermissions[key] = value;
      _hasUnsavedChanges = true;
    });
  }

  void _onManageInviteLink() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this link to invite people to the group:'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://chatfusion.app/invite/project-alpha-team',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showSuccessSnackBar('Link copied to clipboard'),
                    icon: CustomIconWidget(
                      iconName: 'copy',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 5.w,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('New invite link generated');
            },
            child: const Text('Reset Link'),
          ),
        ],
      ),
    );
  }

  void _onGenerateQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'qr_code',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'QR Code Preview',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            const Text('Scan this QR code to join the group'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _showSuccessSnackBar('QR code saved to gallery'),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addMembers() {
    Navigator.pushNamed(context, '/chat-list').then((_) {
      _showSuccessSnackBar('New members added to group');
    });
  }

  void _leaveGroup() {
    _showConfirmationDialog(
      'Leave Group',
      'Are you sure you want to leave this group? You will no longer receive messages.',
      () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/chat-list', (route) => false);
      },
    );
  }

  void _deleteGroup() {
    _showConfirmationDialog(
      'Delete Group',
      'Are you sure you want to delete this group? This action cannot be undone and will remove the group for all members.',
      () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/chat-list', (route) => false);
      },
    );
  }

  void _showConfirmationDialog(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                  'You have unsaved changes. Do you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async => didPop ? true : await _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group Settings'),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: Theme.of(context).colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: () {
                  setState(() => _hasUnsavedChanges = false);
                  _showSuccessSnackBar('Changes saved successfully');
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Group Header
                GroupHeaderWidget(
                  groupData: _groupData,
                  isAdmin: _currentUser["isAdmin"] as bool,
                  onEditPressed: _showEditGroupDialog,
                  onPhotoTap: _showPhotoOptions,
                ),

                SizedBox(height: 3.h),

                // Add Members Button
                if (_currentUser["isAdmin"] as bool ||
                    _groupPermissions["canAddMembers"] as bool)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 3.h),
                    child: ElevatedButton.icon(
                      onPressed: _addMembers,
                      icon: CustomIconWidget(
                        iconName: 'person_add',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      label: const Text('Add Members'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                      ),
                    ),
                  ),

                // Member List
                MemberListWidget(
                  members: (_groupData["members"] as List)
                      .cast<Map<String, dynamic>>(),
                  isAdmin: _currentUser["isAdmin"] as bool,
                  onMemberTap: _onMemberTap,
                  onMakeAdmin: _onMakeAdmin,
                  onRemoveMember: _onRemoveMember,
                  onRestrictMember: _onRestrictMember,
                ),

                SizedBox(height: 3.h),

                // Admin Controls
                AdminControlsWidget(
                  isAdmin: _currentUser["isAdmin"] as bool,
                  groupPermissions: _groupPermissions,
                  onPermissionChanged: _onPermissionChanged,
                  onManageInviteLink: _onManageInviteLink,
                  onGenerateQRCode: _onGenerateQRCode,
                ),

                SizedBox(height: 3.h),

                // Notification Settings
                SettingsSectionWidget(
                  title: 'Notifications',
                  settings: _notificationSettings,
                  onSettingChanged: _onSettingChanged,
                ),

                SizedBox(height: 3.h),

                // Media Settings
                SettingsSectionWidget(
                  title: 'Media & Storage',
                  settings: _mediaSettings,
                  onSettingChanged: _onSettingChanged,
                ),

                SizedBox(height: 3.h),

                // Privacy Settings
                SettingsSectionWidget(
                  title: 'Privacy',
                  settings: _privacySettings,
                  onSettingChanged: _onSettingChanged,
                ),

                SizedBox(height: 3.h),

                // Destructive Actions
                SettingsSectionWidget(
                  title: 'Actions',
                  settings: _destructiveActions,
                  onSettingChanged: _onSettingChanged,
                ),

                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
