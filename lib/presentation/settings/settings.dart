import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_profile_widget.dart';
import './widgets/settings_search_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_toggle_widget.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Settings state variables
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _readReceiptsEnabled = true;
  bool _autoDownloadPhotos = true;
  bool _autoDownloadVideos = false;
  bool _autoDownloadDocuments = false;
  bool _biometricLockEnabled = false;
  bool _twoFactorEnabled = false;
  bool _backupEnabled = true;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;

  // Mock settings data for search functionality
  final List<Map<String, dynamic>> _allSettings = [
    {
      'title': 'Profile',
      'subtitle': 'Manage your profile information',
      'iconName': 'person',
      'section': 'Account',
      'route': '/user-profile',
    },
    {
      'title': 'Privacy',
      'subtitle': 'Control your privacy settings',
      'iconName': 'privacy_tip',
      'section': 'Account',
    },
    {
      'title': 'Security',
      'subtitle': 'Two-factor authentication and more',
      'iconName': 'security',
      'section': 'Account',
    },
    {
      'title': 'Chat Wallpaper',
      'subtitle': 'Customize your chat background',
      'iconName': 'wallpaper',
      'section': 'Chat',
    },
    {
      'title': 'Message Format',
      'subtitle': 'Font size and message appearance',
      'iconName': 'format_size',
      'section': 'Chat',
    },
    {
      'title': 'Notifications',
      'subtitle': 'Message and call notifications',
      'iconName': 'notifications',
      'section': 'Notifications',
    },
    {
      'title': 'Sound',
      'subtitle': 'Notification sounds',
      'iconName': 'volume_up',
      'section': 'Notifications',
    },
    {
      'title': 'Storage Usage',
      'subtitle': 'Manage storage and downloads',
      'iconName': 'storage',
      'section': 'Data',
    },
    {
      'title': 'Auto-Download',
      'subtitle': 'Media download preferences',
      'iconName': 'download',
      'section': 'Data',
    },
    {
      'title': 'Language',
      'subtitle': 'App language settings',
      'iconName': 'language',
      'section': 'Advanced',
    },
    {
      'title': 'Backup',
      'subtitle': 'Chat backup and sync',
      'iconName': 'backup',
      'section': 'Advanced',
    },
    {
      'title': 'Help & Support',
      'subtitle': 'FAQ and contact support',
      'iconName': 'help',
      'section': 'Support',
    },
  ];

  List<Map<String, dynamic>> get _filteredSettings {
    if (_searchQuery.isEmpty) return _allSettings;
    return _allSettings.where((setting) {
      return (setting['title'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (setting['subtitle'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (setting['section'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      textColor: AppTheme.lightTheme.colorScheme.onSurface,
    );
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  void _showComingSoon() {
    _showToast('Feature coming soon!');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.errorLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showToast('Account deletion requires additional verification');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) return SizedBox.shrink();

    final filteredSettings = _filteredSettings;

    if (filteredSettings.isEmpty) {
      return Container(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No settings found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: filteredSettings.asMap().entries.map((entry) {
          final index = entry.key;
          final setting = entry.value;
          final isLast = index == filteredSettings.length - 1;

          return SettingsItemWidget(
            title: setting['title'] as String,
            subtitle: setting['subtitle'] as String,
            iconName: setting['iconName'] as String,
            showDivider: !isLast,
            onTap: setting['route'] != null
                ? () => _navigateToScreen(setting['route'] as String)
                : _showComingSoon,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRegularSettings() {
    if (_searchQuery.isNotEmpty) return SizedBox.shrink();

    return Column(
      children: [
        // Profile Section
        SettingsProfileWidget(
          onTap: () => _navigateToScreen('/user-profile'),
        ),

        // Account Settings
        SettingsSectionWidget(
          title: 'ACCOUNT',
          children: [
            SettingsItemWidget(
              title: 'Privacy',
              subtitle: 'Last seen, profile photo, about',
              iconName: 'privacy_tip',
              onTap: _showComingSoon,
            ),
            SettingsItemWidget(
              title: 'Security',
              subtitle: 'Two-step verification, change number',
              iconName: 'security',
              onTap: _showComingSoon,
            ),
            SettingsItemWidget(
              title: 'Delete My Account',
              subtitle: 'Delete your account and all data',
              iconName: 'delete_forever',
              iconColor: AppTheme.errorLight,
              showDivider: false,
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),

        // Chat Settings
        SettingsSectionWidget(
          title: 'CHATS',
          children: [
            SettingsItemWidget(
              title: 'Chat Wallpaper',
              subtitle: 'Customize your chat background',
              iconName: 'wallpaper',
              onTap: _showComingSoon,
            ),
            SettingsItemWidget(
              title: 'Chat History',
              subtitle: 'Export, clear, and archive chats',
              iconName: 'history',
              onTap: _showComingSoon,
            ),
            SettingsToggleWidget(
              title: 'Read Receipts',
              subtitle: 'Show when messages are read',
              iconName: 'done_all',
              value: _readReceiptsEnabled,
              onChanged: (value) {
                setState(() => _readReceiptsEnabled = value);
                _showToast('Read receipts ${value ? 'enabled' : 'disabled'}');
              },
              showDivider: false,
            ),
          ],
        ),

        // Notifications
        SettingsSectionWidget(
          title: 'NOTIFICATIONS',
          children: [
            SettingsToggleWidget(
              title: 'Notifications',
              subtitle: 'Message and call notifications',
              iconName: 'notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _showToast('Notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsToggleWidget(
              title: 'Sound',
              subtitle: 'Notification sounds',
              iconName: 'volume_up',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
                _showToast('Sound ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsToggleWidget(
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              iconName: 'vibration',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() => _vibrationEnabled = value);
                _showToast('Vibration ${value ? 'enabled' : 'disabled'}');
              },
              showDivider: false,
            ),
          ],
        ),

        // Data and Storage
        SettingsSectionWidget(
          title: 'DATA AND STORAGE',
          children: [
            SettingsItemWidget(
              title: 'Storage Usage',
              subtitle: '2.4 GB used',
              iconName: 'storage',
              onTap: _showComingSoon,
            ),
            SettingsToggleWidget(
              title: 'Auto-Download Photos',
              subtitle: 'Download photos automatically',
              iconName: 'photo',
              value: _autoDownloadPhotos,
              onChanged: (value) {
                setState(() => _autoDownloadPhotos = value);
                _showToast(
                    'Auto-download photos ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsToggleWidget(
              title: 'Auto-Download Videos',
              subtitle: 'Download videos automatically',
              iconName: 'videocam',
              value: _autoDownloadVideos,
              onChanged: (value) {
                setState(() => _autoDownloadVideos = value);
                _showToast(
                    'Auto-download videos ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsToggleWidget(
              title: 'Auto-Download Documents',
              subtitle: 'Download documents automatically',
              iconName: 'description',
              value: _autoDownloadDocuments,
              onChanged: (value) {
                setState(() => _autoDownloadDocuments = value);
                _showToast(
                    'Auto-download documents ${value ? 'enabled' : 'disabled'}');
              },
              showDivider: false,
            ),
          ],
        ),

        // Advanced Settings
        SettingsSectionWidget(
          title: 'ADVANCED',
          children: [
            SettingsToggleWidget(
              title: 'Biometric Lock',
              subtitle: 'Use fingerprint or face unlock',
              iconName: 'fingerprint',
              value: _biometricLockEnabled,
              onChanged: (value) {
                setState(() => _biometricLockEnabled = value);
                _showToast('Biometric lock ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsToggleWidget(
              title: 'Two-Factor Authentication',
              subtitle: 'Add extra security to your account',
              iconName: 'verified_user',
              value: _twoFactorEnabled,
              onChanged: (value) {
                setState(() => _twoFactorEnabled = value);
                _showToast(
                    'Two-factor authentication ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsToggleWidget(
              title: 'Chat Backup',
              subtitle: 'Backup chats to cloud storage',
              iconName: 'backup',
              value: _backupEnabled,
              onChanged: (value) {
                setState(() => _backupEnabled = value);
                _showToast('Chat backup ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsItemWidget(
              title: 'Language',
              subtitle: 'English (US)',
              iconName: 'language',
              onTap: _showComingSoon,
              showDivider: false,
            ),
          ],
        ),

        // Accessibility
        SettingsSectionWidget(
          title: 'ACCESSIBILITY',
          children: [
            SettingsToggleWidget(
              title: 'High Contrast',
              subtitle: 'Increase color contrast',
              iconName: 'contrast',
              value: _highContrastEnabled,
              onChanged: (value) {
                setState(() => _highContrastEnabled = value);
                _showToast('High contrast ${value ? 'enabled' : 'disabled'}');
              },
            ),
            SettingsToggleWidget(
              title: 'Large Text',
              subtitle: 'Increase text size',
              iconName: 'format_size',
              value: _largeTextEnabled,
              onChanged: (value) {
                setState(() => _largeTextEnabled = value);
                _showToast('Large text ${value ? 'enabled' : 'disabled'}');
              },
              showDivider: false,
            ),
          ],
        ),

        // Help and Support
        SettingsSectionWidget(
          title: 'SUPPORT',
          children: [
            SettingsItemWidget(
              title: 'Help & Support',
              subtitle: 'FAQ and contact support',
              iconName: 'help',
              onTap: _showComingSoon,
            ),
            SettingsItemWidget(
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              iconName: 'policy',
              onTap: _showComingSoon,
            ),
            SettingsItemWidget(
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              iconName: 'description',
              onTap: _showComingSoon,
              showDivider: false,
            ),
          ],
        ),

        // App Information
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'ChatFusion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Version 1.0.0 (Build 100)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 0.5.h),
              Text(
                '© 2024 ChatFusion. All rights reserved.',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToScreen('/chat-list'),
            icon: CustomIconWidget(
              iconName: 'home',
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            SettingsSearchWidget(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildSearchResults(),
                    _buildRegularSettings(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
