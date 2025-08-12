import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> settings;
  final Function(String, dynamic) onSettingChanged;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.settings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 2.h),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settings.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final setting = settings[index];
              return _buildSettingItem(context, setting);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, Map<String, dynamic> setting) {
    final String type = setting["type"] as String;
    final String key = setting["key"] as String;
    final String title = setting["title"] as String;
    final String? subtitle = setting["subtitle"] as String?;
    final String iconName = setting["icon"] as String;

    switch (type) {
      case 'switch':
        return SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          secondary: CustomIconWidget(
            iconName: iconName,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
          value: setting["value"] as bool,
          onChanged: (value) => onSettingChanged(key, value),
          activeColor: AppTheme.lightTheme.primaryColor,
        );

      case 'selection':
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: CustomIconWidget(
            iconName: iconName,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            setting["value"] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                ),
          ),
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          onTap: () => _showSelectionDialog(context, setting),
        );

      case 'action':
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: CustomIconWidget(
            iconName: iconName,
            color: setting["isDestructive"] == true
                ? AppTheme.errorLight
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: setting["isDestructive"] == true
                      ? AppTheme.errorLight
                      : null,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          onTap: () => onSettingChanged(key, null),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _showSelectionDialog(
      BuildContext context, Map<String, dynamic> setting) {
    final List<String> options = (setting["options"] as List).cast<String>();
    final String currentValue = setting["value"] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(setting["title"] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: currentValue,
              onChanged: (value) {
                if (value != null) {
                  onSettingChanged(setting["key"] as String, value);
                  Navigator.of(context).pop();
                }
              },
              activeColor: AppTheme.lightTheme.primaryColor,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
