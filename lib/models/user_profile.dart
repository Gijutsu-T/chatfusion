class UserProfile {
  final String id;
  final String email;
  final String? username;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final String status;
  final bool isOnline;
  final DateTime lastSeen;
  final String role;
  final bool isActive;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> privacySettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.username,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.status = 'offline',
    this.isOnline = false,
    required this.lastSeen,
    this.role = 'member',
    this.isActive = true,
    this.notificationSettings = const {
      "push": true,
      "email": true,
      "desktop": true
    },
    this.privacySettings = const {
      "read_receipts": true,
      "last_seen": true,
      "profile_photo": true
    },
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      phone: json['phone'],
      status: json['status'] ?? 'offline',
      isOnline: json['is_online'] ?? false,
      lastSeen:
          DateTime.parse(json['last_seen'] ?? DateTime.now().toIso8601String()),
      role: json['role'] ?? 'member',
      isActive: json['is_active'] ?? true,
      notificationSettings: json['notification_settings'] ??
          {"push": true, "email": true, "desktop": true},
      privacySettings: json['privacy_settings'] ??
          {"read_receipts": true, "last_seen": true, "profile_photo": true},
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone': phone,
      'status': status,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
      'role': role,
      'is_active': isActive,
      'notification_settings': notificationSettings,
      'privacy_settings': privacySettings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? phone,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
    String? role,
    bool? isActive,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? privacySettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
