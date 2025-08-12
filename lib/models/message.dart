import './user_profile.dart';

class Message {
  final String id;
  final String chatId;
  final String? senderId;
  final String? parentMessageId;
  final String? content;
  final String messageType;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final String? thumbnailUrl;
  final Map<String, dynamic> metadata;
  final bool isEdited;
  final int editCount;
  final bool isDeleted;
  final bool isPinned;
  final Map<String, dynamic> reactions;
  final List<String> mentions;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserProfile? sender;
  final Message? parentMessage;

  Message({
    required this.id,
    required this.chatId,
    this.senderId,
    this.parentMessageId,
    this.content,
    this.messageType = 'text',
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.thumbnailUrl,
    this.metadata = const {},
    this.isEdited = false,
    this.editCount = 0,
    this.isDeleted = false,
    this.isPinned = false,
    this.reactions = const {},
    this.mentions = const [],
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.parentMessage,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      chatId: json['chat_id'] ?? '',
      senderId: json['sender_id'],
      parentMessageId: json['parent_message_id'],
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      fileType: json['file_type'],
      thumbnailUrl: json['thumbnail_url'],
      metadata: json['metadata'] ?? {},
      isEdited: json['is_edited'] ?? false,
      editCount: json['edit_count'] ?? 0,
      isDeleted: json['is_deleted'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      reactions: json['reactions'] ?? {},
      mentions: List<String>.from(json['mentions'] ?? []),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      sender:
          json['sender'] != null ? UserProfile.fromJson(json['sender']) : null,
      parentMessage: json['parent_message'] != null
          ? Message.fromJson(json['parent_message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'parent_message_id': parentMessageId,
      'content': content,
      'message_type': messageType,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'file_type': fileType,
      'thumbnail_url': thumbnailUrl,
      'metadata': metadata,
      'is_edited': isEdited,
      'edit_count': editCount,
      'is_deleted': isDeleted,
      'is_pinned': isPinned,
      'reactions': reactions,
      'mentions': mentions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sender': sender?.toJson(),
      'parent_message': parentMessage?.toJson(),
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? parentMessageId,
    String? content,
    String? messageType,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    bool? isEdited,
    int? editCount,
    bool? isDeleted,
    bool? isPinned,
    Map<String, dynamic>? reactions,
    List<String>? mentions,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? sender,
    Message? parentMessage,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
      isEdited: isEdited ?? this.isEdited,
      editCount: editCount ?? this.editCount,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      reactions: reactions ?? this.reactions,
      mentions: mentions ?? this.mentions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      parentMessage: parentMessage ?? this.parentMessage,
    );
  }
}
