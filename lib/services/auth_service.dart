import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (error) {
      throw Exception('Google sign in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update user profile
  Future<UserProfile> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? phone,
    String? avatarUrl,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? privacySettings,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (notificationSettings != null)
        updates['notification_settings'] = notificationSettings;
      if (privacySettings != null)
        updates['privacy_settings'] = privacySettings;

      if (updates.isEmpty) throw Exception('No updates provided');

      final response = await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  // Update user status
  Future<void> updateUserStatus(String status) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('user_profiles').update({
        'status': status,
        'is_online': status != 'offline',
      }).eq('id', user.id);
    } catch (error) {
      throw Exception('Status update failed: $error');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Refresh session
  Future<AuthResponse?> refreshSession() async {
    try {
      return await _client.auth.refreshSession();
    } catch (error) {
      return null;
    }
  }
}
