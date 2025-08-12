import './user_profile.dart';

class ChatMember {
  final String id;
  final String chatId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final bool isAdmin;
  final bool isModerator;
  final bool canSendMessages;
  final bool canAddMembers;
  final bool canEditInfo;
  final bool notificationsEnabled;

  // Related data
  final UserProfile? userProfile;

  ChatMember({
    required this.id,
    required this.chatId,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
    this.isAdmin = false,
    this.isModerator = false,
    this.canSendMessages = true,
    this.canAddMembers = false,
    this.canEditInfo = false,
    this.notificationsEnabled = true,
    this.userProfile,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      id: json['id'] ?? '',
      chatId: json['chat_id'] ?? '',
      userId: json['user_id'] ?? '',
      role: json['role'] ?? 'member',
      joinedAt:
          DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
      isAdmin: json['is_admin'] ?? false,
      isModerator: json['is_moderator'] ?? false,
      canSendMessages: json['can_send_messages'] ?? true,
      canAddMembers: json['can_add_members'] ?? false,
      canEditInfo: json['can_edit_info'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      userProfile: json['user_profile'] != null
          ? UserProfile.fromJson(json['user_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'is_admin': isAdmin,
      'is_moderator': isModerator,
      'can_send_messages': canSendMessages,
      'can_add_members': canAddMembers,
      'can_edit_info': canEditInfo,
      'notifications_enabled': notificationsEnabled,
      'user_profile': userProfile?.toJson(),
    };
  }

  ChatMember copyWith({
    String? id,
    String? chatId,
    String? userId,
    String? role,
    DateTime? joinedAt,
    bool? isAdmin,
    bool? isModerator,
    bool? canSendMessages,
    bool? canAddMembers,
    bool? canEditInfo,
    bool? notificationsEnabled,
    UserProfile? userProfile,
  }) {
    return ChatMember(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isAdmin: isAdmin ?? this.isAdmin,
      isModerator: isModerator ?? this.isModerator,
      canSendMessages: canSendMessages ?? this.canSendMessages,
      canAddMembers: canAddMembers ?? this.canAddMembers,
      canEditInfo: canEditInfo ?? this.canEditInfo,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}
