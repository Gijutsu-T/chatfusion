import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/app_export.dart';
import '../../../models/message.dart';
import '../../../theme/app_theme.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final VoidCallback? onLongPress;
  final Function(String)? onReaction;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.isOwnMessage,
    this.onLongPress,
    this.onReaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        child: Row(
          mainAxisAlignment:
              isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOwnMessage) ...[
              CircleAvatar(
                radius: 3.w,
                backgroundImage: NetworkImage(
                  message.sender?.avatarUrl ??
                      "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
                ),
              ),
              SizedBox(width: 2.w),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isOwnMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isOwnMessage && message.sender != null)
                    Padding(
                      padding: EdgeInsets.only(left: 3.w, bottom: 0.5.h),
                      child: Text(
                        message.sender!.fullName,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 2.w,
                    ),
                    decoration: BoxDecoration(
                      color: isOwnMessage
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.w),
                        topRight: Radius.circular(4.w),
                        bottomLeft: isOwnMessage
                            ? Radius.circular(4.w)
                            : Radius.circular(1.w),
                        bottomRight: isOwnMessage
                            ? Radius.circular(1.w)
                            : Radius.circular(4.w),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.parentMessageId != null &&
                            message.parentMessage != null)
                          Container(
                            padding: EdgeInsets.all(2.w),
                            margin: EdgeInsets.only(bottom: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.parentMessage!.sender?.fullName ??
                                      'Unknown',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  message.parentMessage!.content ?? '',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        _buildMessageContent(),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeago.format(message.createdAt),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: isOwnMessage
                                    ? Colors.white70
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                fontSize: 10.sp,
                              ),
                            ),
                            if (message.isEdited)
                              Text(
                                ' • edited',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: isOwnMessage
                                      ? Colors.white70
                                      : AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                  fontSize: 10.sp,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            if (isOwnMessage) ...[
                              SizedBox(width: 1.w),
                              Icon(
                                Icons.done_all,
                                size: 3.w,
                                color: Colors.white70,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (message.reactions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 0.5.h),
                      child: Wrap(
                        spacing: 1.w,
                        children: message.reactions.entries.map((entry) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(3.w),
                              border: Border.all(
                                color: AppTheme.lightTheme.dividerColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(entry.key,
                                    style: TextStyle(fontSize: 12.sp)),
                                SizedBox(width: 1.w),
                                Text(
                                  entry.value.toString(),
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            if (isOwnMessage) SizedBox(width: 2.w),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.messageType) {
      case 'image':
        return _buildImageMessage();
      case 'document':
      case 'file':
        return _buildFileMessage();
      case 'voice':
        return _buildVoiceMessage();
      case 'location':
        return _buildLocationMessage();
      default:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message.content ?? '',
      style: TextStyle(
        color: isOwnMessage
            ? Colors.white
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _buildImageMessage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.w),
      child: message.fileUrl != null
          ? CachedNetworkImage(
              imageUrl: message.fileUrl!,
              width: 60.w,
              height: 40.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60.w,
                height: 40.w,
                color: Colors.grey[300],
                child: Icon(Icons.image_outlined),
              ),
              errorWidget: (context, url, error) => Container(
                width: 60.w,
                height: 40.w,
                color: Colors.grey[300],
                child: Icon(Icons.error_outline),
              ),
            )
          : Container(
              width: 60.w,
              height: 40.w,
              color: Colors.grey[300],
              child: Icon(Icons.image_outlined),
            ),
    );
  }

  Widget _buildFileMessage() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(),
            size: 6.w,
            color: isOwnMessage
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: TextStyle(
                    color: isOwnMessage
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message.fileSize != null)
                  Text(
                    _formatFileSize(message.fileSize!),
                    style: TextStyle(
                      color: isOwnMessage
                          ? Colors.white70
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            size: 6.w,
            color: isOwnMessage
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Container(
            width: 30.w,
            height: 1.w,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(0.5.w),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '0:30',
            style: TextStyle(
              color: isOwnMessage
                  ? Colors.white70
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 6.w,
            color: isOwnMessage
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Text(
            'Location',
            style: TextStyle(
              color: isOwnMessage
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    final fileType = message.fileType?.toLowerCase() ?? '';
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('doc')) return Icons.description;
    if (fileType.contains('image')) return Icons.image;
    if (fileType.contains('video')) return Icons.videocam;
    if (fileType.contains('audio')) return Icons.audiotrack;
    return Icons.attach_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
