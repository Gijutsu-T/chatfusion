class Chat {
  final String id;
  final String chatType;
  final String? name;
  final String? description;
  final String? avatarUrl;
  final String? createdBy;
  final bool isArchived;
  final bool isMuted;
  final bool isPinned;
  final int memberCount;
  final int maxMembers;
  final String? inviteLink;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    required this.id,
    this.chatType = 'direct',
    this.name,
    this.description,
    this.avatarUrl,
    this.createdBy,
    this.isArchived = false,
    this.isMuted = false,
    this.isPinned = false,
    this.memberCount = 0,
    this.maxMembers = 1000,
    this.inviteLink,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      chatType: json['chat_type'] ?? 'direct',
      name: json['name'],
      description: json['description'],
      avatarUrl: json['avatar_url'],
      createdBy: json['created_by'],
      isArchived: json['is_archived'] ?? false,
      isMuted: json['is_muted'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      memberCount: json['member_count'] ?? 0,
      maxMembers: json['max_members'] ?? 1000,
      inviteLink: json['invite_link'],
      settings: json['settings'] ?? {},
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_type': chatType,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'created_by': createdBy,
      'is_archived': isArchived,
      'is_muted': isMuted,
      'is_pinned': isPinned,
      'member_count': memberCount,
      'max_members': maxMembers,
      'invite_link': inviteLink,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Chat copyWith({
    String? id,
    String? chatType,
    String? name,
    String? description,
    String? avatarUrl,
    String? createdBy,
    bool? isArchived,
    bool? isMuted,
    bool? isPinned,
    int? memberCount,
    int? maxMembers,
    String? inviteLink,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      chatType: chatType ?? this.chatType,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      inviteLink: inviteLink ?? this.inviteLink,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
