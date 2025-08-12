import 'package:flutter/material.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/settings/settings.dart';
import '../presentation/chat_list/chat_list.dart';
import '../presentation/voice_video_call/voice_video_call.dart';
import '../presentation/chat_detail/chat_detail.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/group_chat_settings/group_chat_settings.dart';

class AppRoutes {
  // Authentication routes
  static const String login = '/login';
  static const String signup = '/signup';

  // Main app routes
  static const String initial = '/';
  static const String settings = '/settings';
  static const String chatList = '/chat-list';
  static const String voiceVideoCall = '/voice-video-call';
  static const String chatDetail = '/chat-detail';
  static const String userProfile = '/user-profile';
  static const String groupChatSettings = '/group-chat-settings';

  static Map<String, WidgetBuilder> routes = {
    // Auth routes
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),

    // Main routes - will be protected by auth guard
    initial: (context) => const LoginScreen(),
    settings: (context) => const Settings(),
    chatList: (context) => const ChatList(),
    voiceVideoCall: (context) => const VoiceVideoCall(),
    chatDetail: (context) => const ChatDetail(),
    userProfile: (context) => UserProfile(),
    groupChatSettings: (context) => const GroupChatSettings(),
  };
}
