import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatItemWidget extends StatelessWidget {
  final Map<String, dynamic> chatData;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onPin;
  final VoidCallback onMute;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;
  final VoidCallback onBlock;
  final VoidCallback onExport;

  const ChatItemWidget({
    Key? key,
    required this.chatData,
    required this.onTap,
    required this.onArchive,
    required this.onPin,
    required this.onMute,
    required this.onDelete,
    required this.onMarkAsRead,
    required this.onBlock,
    required this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isOnline = chatData['isOnline'] ?? false;
    final bool isPinned = chatData['isPinned'] ?? false;
    final int unreadCount = chatData['unreadCount'] ?? 0;
    final bool isGroup = chatData['isGroup'] ?? false;
    final bool hasFailedMessage = chatData['hasFailedMessage'] ?? false;
    final bool isTyping = chatData['isTyping'] ?? false;
    final String messageType = chatData['lastMessageType'] ?? 'text';

    return Dismissible(
      key: Key(chatData['id'].toString()),
      background: _buildSwipeBackground(isLeft: false),
      secondaryBackground: _buildSwipeBackground(isLeft: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onArchive();
        } else {
          onDelete();
        }
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: isPinned
                ? AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.lightTheme.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.w),
                      child: CustomImageWidget(
                        imageUrl: chatData['avatar'] ?? '',
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isOnline && !isGroup)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 3.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          color: AppTheme.successLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  if (isPinned)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'push_pin',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 2.w,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 3.w),

              // Chat content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name and group info
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  chatData['name'] ?? '',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isGroup) ...[
                                SizedBox(width: 1.w),
                                CustomIconWidget(
                                  iconName: 'group',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 3.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${chatData['memberCount'] ?? 0}',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Timestamp and status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTimestamp(chatData['timestamp']),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: unreadCount > 0
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                            if (hasFailedMessage)
                              Padding(
                                padding: EdgeInsets.only(top: 0.5.h),
                                child: CustomIconWidget(
                                  iconName: 'error',
                                  color: AppTheme.errorLight,
                                  size: 3.w,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),

                    // Last message preview
                    Row(
                      children: [
                        Expanded(
                          child: isTyping
                              ? _buildTypingIndicator()
                              : _buildLastMessage(messageType),
                        ),

                        // Unread badge
                        if (unreadCount > 0)
                          Container(
                            margin: EdgeInsets.only(left: 2.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 5.w,
                              minHeight: 2.5.h,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      color: isLeft
          ? AppTheme.errorLight
          : AppTheme.lightTheme.colorScheme.primaryContainer,
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isLeft ? 'delete' : 'archive',
            color:
                isLeft ? Colors.white : AppTheme.lightTheme.colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            isLeft ? 'Delete' : 'Archive',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: isLeft
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Text(
          'typing',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(width: 1.w),
        SizedBox(
          width: 4.w,
          height: 1.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              return Container(
                width: 0.8.w,
                height: 0.8.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLastMessage(String messageType) {
    String messageText = chatData['lastMessage'] ?? '';
    IconData? messageIcon;

    switch (messageType) {
      case 'voice':
        messageIcon = Icons.mic;
        messageText = 'Voice message';
        break;
      case 'image':
        messageIcon = Icons.image;
        messageText = 'Photo';
        break;
      case 'video':
        messageIcon = Icons.videocam;
        messageText = 'Video';
        break;
      case 'document':
        messageIcon = Icons.description;
        messageText = 'Document';
        break;
      case 'location':
        messageIcon = Icons.location_on;
        messageText = 'Location';
        break;
    }

    return Row(
      children: [
        if (messageIcon != null) ...[
          CustomIconWidget(
            iconName: messageIcon.toString().split('.').last,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
        ],
        Expanded(
          child: Text(
            messageText,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContextMenuItem(
              context,
              'Mark as Read',
              Icons.mark_email_read,
              onMarkAsRead,
            ),
            _buildContextMenuItem(
              context,
              'Pin Chat',
              Icons.push_pin,
              onPin,
            ),
            _buildContextMenuItem(
              context,
              'Mute Notifications',
              Icons.notifications_off,
              onMute,
            ),
            _buildContextMenuItem(
              context,
              'Archive',
              Icons.archive,
              onArchive,
            ),
            _buildContextMenuItem(
              context,
              'Export Chat',
              Icons.download,
              onExport,
            ),
            _buildContextMenuItem(
              context,
              'Block User',
              Icons.block,
              onBlock,
              isDestructive: true,
            ),
            _buildContextMenuItem(
              context,
              'Delete Chat',
              Icons.delete,
              onDelete,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon.toString().split('.').last,
        color: isDestructive
            ? AppTheme.errorLight
            : AppTheme.lightTheme.colorScheme.onSurface,
        size: 5.w,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isDestructive
              ? AppTheme.errorLight
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
