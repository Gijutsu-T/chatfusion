import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/contact_info_widget.dart';
import './widgets/photo_edit_bottom_sheet.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/storage_usage_widget.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Sarah Johnson",
    "username": "@sarah_j",
    "phone": "+1 (555) 123-4567",
    "email": "sarah.johnson@email.com",
    "profileImage":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "status": "Building the future, one line of code at a time 🚀",
    "phoneVisible": true,
    "usernameVisible": true,
    "lastSeen": "2 hours ago",
    "joinDate": "January 2023"
  };

  // Storage data
  final List<StorageItem> storageItems = [
    StorageItem(
      category: "Photos & Videos",
      icon: 'photo_library',
      size: 2.4,
      color: AppTheme.lightTheme.primaryColor,
    ),
    StorageItem(
      category: "Documents",
      icon: 'description',
      size: 0.8,
      color: Colors.orange,
    ),
    StorageItem(
      category: "Voice Messages",
      icon: 'mic',
      size: 0.3,
      color: Colors.green,
    ),
    StorageItem(
      category: "Other Files",
      icon: 'folder',
      size: 0.2,
      color: Colors.purple,
    ),
  ];

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    final double totalStorage =
        storageItems.fold(0.0, (sum, item) => sum + item.size);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(
              profileImageUrl: userData["profileImage"] as String,
              userName: userData["name"] as String,
              statusMessage: userData["status"] as String,
              onEditPhoto: _showPhotoEditBottomSheet,
              onEditStatus: _showStatusEditDialog,
            ),
            SizedBox(height: 2.h),

            // Contact Information
            ContactInfoWidget(
              phoneNumber: userData["phone"] as String,
              username: userData["username"] as String,
              phoneVisible: userData["phoneVisible"] as bool,
              usernameVisible: userData["usernameVisible"] as bool,
              onPhoneVisibilityChanged: (value) {
                setState(() {
                  userData["phoneVisible"] = value;
                });
              },
              onUsernameVisibilityChanged: (value) {
                setState(() {
                  userData["usernameVisible"] = value;
                });
              },
            ),

            // Account Settings
            SettingsSectionWidget(
              title: "Account",
              items: [
                SettingsItem(
                  icon: 'person',
                  title: "Change Username",
                  subtitle: userData["username"] as String,
                  onTap: _showUsernameEditDialog,
                ),
                SettingsItem(
                  icon: 'phone',
                  title: "Change Phone Number",
                  subtitle: userData["phone"] as String,
                  onTap: _showPhoneEditDialog,
                ),
                SettingsItem(
                  icon: 'email',
                  title: "Email Address",
                  subtitle: userData["email"] as String,
                  onTap: _showEmailEditDialog,
                ),
              ],
            ),

            // Privacy Settings
            SettingsSectionWidget(
              title: "Privacy",
              items: [
                SettingsItem(
                  icon: 'visibility',
                  title: "Last Seen",
                  subtitle: "Visible to contacts",
                  onTap: _showLastSeenSettings,
                ),
                SettingsItem(
                  icon: 'photo',
                  title: "Profile Photo",
                  subtitle: "Visible to everyone",
                  onTap: _showProfilePhotoSettings,
                ),
                SettingsItem(
                  icon: 'info',
                  title: "Status",
                  subtitle: "Visible to contacts",
                  onTap: _showStatusSettings,
                ),
                SettingsItem(
                  icon: 'block',
                  title: "Blocked Contacts",
                  subtitle: "Manage blocked users",
                  onTap: _showBlockedContacts,
                ),
              ],
            ),

            // Notifications
            SettingsSectionWidget(
              title: "Notifications",
              items: [
                SettingsItem(
                  icon: 'notifications',
                  title: "Message Notifications",
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: AppTheme.lightTheme.primaryColor,
                  ),
                ),
                SettingsItem(
                  icon: 'group',
                  title: "Group Notifications",
                  subtitle: "Mentions only",
                  onTap: _showGroupNotificationSettings,
                ),
                SettingsItem(
                  icon: 'call',
                  title: "Call Notifications",
                  subtitle: "Enabled",
                  onTap: _showCallNotificationSettings,
                ),
              ],
            ),

            // Chat Settings
            SettingsSectionWidget(
              title: "Chat Settings",
              items: [
                SettingsItem(
                  icon: 'wallpaper',
                  title: "Chat Wallpaper",
                  subtitle: "Default",
                  onTap: _showWallpaperSettings,
                ),
                SettingsItem(
                  icon: 'text_fields',
                  title: "Font Size",
                  subtitle: "Medium",
                  onTap: _showFontSizeSettings,
                ),
                SettingsItem(
                  icon: 'backup',
                  title: "Chat Backup",
                  subtitle: "Last backup: Yesterday",
                  onTap: _showBackupSettings,
                ),
              ],
            ),

            // Security
            SettingsSectionWidget(
              title: "Security",
              items: [
                SettingsItem(
                  icon: 'security',
                  title: "Two-Factor Authentication",
                  trailing: Switch(
                    value: _twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                      _showTwoFactorDialog(value);
                    },
                    activeColor: AppTheme.lightTheme.primaryColor,
                  ),
                ),
                SettingsItem(
                  icon: 'fingerprint',
                  title: "Biometric App Lock",
                  subtitle: "Enabled",
                  onTap: _showBiometricSettings,
                ),
                SettingsItem(
                  icon: 'devices',
                  title: "Active Sessions",
                  subtitle: "3 devices",
                  onTap: _showActiveSessions,
                ),
              ],
            ),

            // Storage Usage
            StorageUsageWidget(
              totalStorage: totalStorage,
              storageItems: storageItems,
              onCleanup: _showStorageCleanupDialog,
            ),

            // Theme Settings
            SettingsSectionWidget(
              title: "Appearance",
              items: [
                SettingsItem(
                  icon: 'dark_mode',
                  title: "Dark Mode",
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                    },
                    activeColor: AppTheme.lightTheme.primaryColor,
                  ),
                ),
                SettingsItem(
                  icon: 'palette',
                  title: "Theme Color",
                  subtitle: "Blue",
                  onTap: _showThemeColorSettings,
                ),
              ],
            ),

            // About
            SettingsSectionWidget(
              title: "About",
              items: [
                SettingsItem(
                  icon: 'info_outline',
                  title: "App Version",
                  subtitle: "ChatFusion v2.1.0",
                ),
                SettingsItem(
                  icon: 'description',
                  title: "Terms of Service",
                  onTap: _showTermsOfService,
                ),
                SettingsItem(
                  icon: 'privacy_tip',
                  title: "Privacy Policy",
                  onTap: _showPrivacyPolicy,
                ),
                SettingsItem(
                  icon: 'help_outline',
                  title: "Help & Support",
                  onTap: _showHelpSupport,
                ),
              ],
            ),

            // Logout Button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showLogoutDialog,
                icon: CustomIconWidget(
                  iconName: 'logout',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _showPhotoEditBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoEditBottomSheet(
        onPhotoSelected: (imagePath) {
          setState(() {
            userData["profileImage"] = imagePath;
          });
        },
      ),
    );
  }

  void _showStatusEditDialog() {
    final TextEditingController controller = TextEditingController(
      text: userData["status"] as String,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Status"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 150,
          decoration: InputDecoration(
            hintText: "What's on your mind?",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData["status"] = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showUsernameEditDialog() {
    final TextEditingController controller = TextEditingController(
      text: (userData["username"] as String).replaceFirst('@', ''),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Username"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixText: "@",
            hintText: "Enter username",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData["username"] = "@${controller.text}";
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showPhoneEditDialog() {
    final TextEditingController controller = TextEditingController(
      text: userData["phone"] as String,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Phone Number"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "Enter phone number",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData["phone"] = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEmailEditDialog() {
    final TextEditingController controller = TextEditingController(
      text: userData["email"] as String,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Email Address"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter email address",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData["email"] = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enabled
            ? "Enable Two-Factor Authentication"
            : "Disable Two-Factor Authentication"),
        content: Text(
          enabled
              ? "Two-factor authentication adds an extra layer of security to your account. You'll need to enter a code from your authenticator app when signing in."
              : "Are you sure you want to disable two-factor authentication? This will make your account less secure.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _twoFactorEnabled = !enabled;
              });
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(enabled ? "Enable" : "Disable"),
          ),
        ],
      ),
    );
  }

  void _showStorageCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clean Up Storage"),
        content: Text(
            "This will remove cached files and temporary data. Your messages and media will not be affected."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Storage cleaned successfully")),
              );
            },
            child: Text("Clean Up"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout from ChatFusion?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/chat-list', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Placeholder methods for other settings
  void _showLastSeenSettings() {}
  void _showProfilePhotoSettings() {}
  void _showStatusSettings() {}
  void _showBlockedContacts() {}
  void _showGroupNotificationSettings() {}
  void _showCallNotificationSettings() {}
  void _showWallpaperSettings() {}
  void _showFontSizeSettings() {}
  void _showBackupSettings() {}
  void _showBiometricSettings() {}
  void _showActiveSessions() {}
  void _showThemeColorSettings() {}
  void _showTermsOfService() {}
  void _showPrivacyPolicy() {}
  void _showHelpSupport() {}
}
