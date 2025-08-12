import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdminControlsWidget extends StatelessWidget {
  final bool isAdmin;
  final Map<String, dynamic> groupPermissions;
  final Function(String, dynamic) onPermissionChanged;
  final VoidCallback onManageInviteLink;
  final VoidCallback onGenerateQRCode;

  const AdminControlsWidget({
    Key? key,
    required this.isAdmin,
    required this.groupPermissions,
    required this.onPermissionChanged,
    required this.onManageInviteLink,
    required this.onGenerateQRCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) return const SizedBox.shrink();

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
              'Admin Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _buildPermissionSection(context),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          _buildInviteLinkSection(context),
        ],
      ),
    );
  }

  Widget _buildPermissionSection(BuildContext context) {
    return ExpansionTile(
      leading: CustomIconWidget(
        iconName: 'security',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 6.w,
      ),
      title: Text(
        'Member Permissions',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: [
        SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.5.h),
          title: Text(
            'Send Messages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            'Allow members to send messages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: groupPermissions["canSendMessages"] as bool,
          onChanged: (value) => onPermissionChanged("canSendMessages", value),
          activeColor: AppTheme.lightTheme.primaryColor,
        ),
        SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.5.h),
          title: Text(
            'Add Members',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            'Allow members to add new participants',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: groupPermissions["canAddMembers"] as bool,
          onChanged: (value) => onPermissionChanged("canAddMembers", value),
          activeColor: AppTheme.lightTheme.primaryColor,
        ),
        SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.5.h),
          title: Text(
            'Edit Group Info',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            'Allow members to edit group details',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: groupPermissions["canEditInfo"] as bool,
          onChanged: (value) => onPermissionChanged("canEditInfo", value),
          activeColor: AppTheme.lightTheme.primaryColor,
        ),
        SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.5.h),
          title: Text(
            'Pin Messages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            'Allow members to pin important messages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: groupPermissions["canPinMessages"] as bool,
          onChanged: (value) => onPermissionChanged("canPinMessages", value),
          activeColor: AppTheme.lightTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildInviteLinkSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: CustomIconWidget(
            iconName: 'link',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          title: Text(
            'Invite Link',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            'Manage group invitation link',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          onTap: onManageInviteLink,
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: CustomIconWidget(
            iconName: 'qr_code',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          title: Text(
            'QR Code',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            'Generate QR code for easy joining',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          onTap: onGenerateQRCode,
        ),
        SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          secondary: CustomIconWidget(
            iconName: 'approval',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          title: Text(
            'Approve New Members',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            'Require admin approval for new joins',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: groupPermissions["requireApproval"] as bool,
          onChanged: (value) => onPermissionChanged("requireApproval", value),
          activeColor: AppTheme.lightTheme.primaryColor,
        ),
      ],
    );
  }
}
