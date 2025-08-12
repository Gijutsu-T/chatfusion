import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContactInfoWidget extends StatelessWidget {
  final String phoneNumber;
  final String username;
  final bool phoneVisible;
  final bool usernameVisible;
  final Function(bool) onPhoneVisibilityChanged;
  final Function(bool) onUsernameVisibilityChanged;

  const ContactInfoWidget({
    Key? key,
    required this.phoneNumber,
    required this.username,
    required this.phoneVisible,
    required this.usernameVisible,
    required this.onPhoneVisibilityChanged,
    required this.onUsernameVisibilityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Information",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Phone Number
          _buildContactItem(
            icon: 'phone',
            label: "Phone Number",
            value: phoneNumber,
            isVisible: phoneVisible,
            onVisibilityChanged: onPhoneVisibilityChanged,
          ),
          SizedBox(height: 2.h),

          // Username
          _buildContactItem(
            icon: 'alternate_email',
            label: "Username",
            value: username,
            isVisible: usernameVisible,
            onVisibilityChanged: onUsernameVisibilityChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required String icon,
    required String label,
    required String value,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.primaryColor,
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isVisible,
          onChanged: onVisibilityChanged,
          activeColor: AppTheme.lightTheme.primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
