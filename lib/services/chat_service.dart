import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat.dart';
import '../models/chat_member.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import './supabase_service.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ChatService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all chats for current user
  Future<List<Chat>> getUserChats() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('chats')
          .select('''
            *,
            chat_members!inner(user_id)
          ''')
          .eq('chat_members.user_id', userId)
          .order('updated_at', ascending: false);

      return response.map((json) => Chat.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get user chats: $error');
    }
  }

  // Get chat by ID with members
  Future<Chat?> getChatById(String chatId) async {
    try {
      final response =
          await _client.from('chats').select('*').eq('id', chatId).single();

      return Chat.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get chat: $error');
    }
  }

  // Get chat members
  Future<List<ChatMember>> getChatMembers(String chatId) async {
    try {
      final response = await _client.from('chat_members').select('''
            *,
            user_profile:user_profiles(*)
          ''').eq('chat_id', chatId);

      return response.map((json) => ChatMember.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get chat members: $error');
    }
  }

  // Create direct chat
  Future<String> createDirectChat(String otherUserId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Use stored function to get or create direct chat
      final response = await _client.rpc('get_or_create_direct_chat',
          params: {'user1_uuid': userId, 'user2_uuid': otherUserId});

      return response as String;
    } catch (error) {
      throw Exception('Failed to create direct chat: $error');
    }
  }

  // Create group chat
  Future<Chat> createGroupChat({
    required String name,
    String? description,
    required List<String> memberIds,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Create the chat
      final chatResponse = await _client
          .from('chats')
          .insert({
            'chat_type': 'group',
            'name': name,
            'description': description,
            'created_by': userId,
          })
          .select()
          .single();

      final chat = Chat.fromJson(chatResponse);

      // Add creator as admin member
      await _client.from('chat_members').insert({
        'chat_id': chat.id,
        'user_id': userId,
        'is_admin': true,
      });

      // Add other members
      if (memberIds.isNotEmpty) {
        final memberInserts = memberIds
            .map((memberId) => {
                  'chat_id': chat.id,
                  'user_id': memberId,
                })
            .toList();

        await _client.from('chat_members').insert(memberInserts);
      }

      return chat;
    } catch (error) {
      throw Exception('Failed to create group chat: $error');
    }
  }

  // Get messages for a chat
  Future<List<Message>> getChatMessages(String chatId,
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await _client
          .from('messages')
          .select('''
            *,
            sender:user_profiles!sender_id(*),
            parent_message:messages!parent_message_id(
              *,
              sender:user_profiles!sender_id(*)
            )
          ''')
          .eq('chat_id', chatId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => Message.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get messages: $error');
    }
  }

  // Send message
  Future<Message> sendMessage({
    required String chatId,
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    String? parentMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': userId,
        'content': content,
        'message_type': messageType,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'file_type': fileType,
        'parent_message_id': parentMessageId,
        'metadata': metadata,
      }).select('''
            *,
            sender:user_profiles!sender_id(*)
          ''').single();

      return Message.fromJson(response);
    } catch (error) {
      throw Exception('Failed to send message: $error');
    }
  }

  // Update message
  Future<Message> updateMessage(String messageId, String newContent) async {
    try {
      final response = await _client
          .from('messages')
          .update({
            'content': newContent,
            'is_edited': true,
          })
          .eq('id', messageId)
          .select('''
            *,
            sender:user_profiles!sender_id(*)
          ''')
          .single();

      return Message.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update message: $error');
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _client
          .from('messages')
          .update({'is_deleted': true}).eq('id', messageId);
    } catch (error) {
      throw Exception('Failed to delete message: $error');
    }
  }

  // Add reaction to message
  Future<void> addReaction(String messageId, String emoji) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('message_reactions').upsert({
        'message_id': messageId,
        'user_id': userId,
        'emoji': emoji,
      });
    } catch (error) {
      throw Exception('Failed to add reaction: $error');
    }
  }

  // Remove reaction from message
  Future<void> removeReaction(String messageId, String emoji) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', userId)
          .eq('emoji', emoji);
    } catch (error) {
      throw Exception('Failed to remove reaction: $error');
    }
  }

  // Update user online status
  Future<void> updateUserActivity() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.rpc('update_user_activity', params: {'user_uuid': userId});
    } catch (error) {
      throw Exception('Failed to update user activity: $error');
    }
  }

  // Set user offline
  Future<void> setUserOffline() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.from('user_profiles').update({
        'is_online': false,
        'status': 'offline',
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to set user offline: $error');
    }
  }

  // Subscribe to chat messages
  RealtimeChannel subscribeToChatMessages(
      String chatId, Function(Message) onMessageReceived) {
    return _client
        .channel('messages:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) async {
            try {
              // Fetch complete message with sender info
              final messageResponse = await _client.from('messages').select('''
                    *,
                    sender:user_profiles!sender_id(*)
                  ''').eq('id', payload.newRecord['id']).single();

              final message = Message.fromJson(messageResponse);
              onMessageReceived(message);
            } catch (error) {
              print('Error processing message: $error');
            }
          },
        )
        .subscribe();
  }

  // Subscribe to user chats
  RealtimeChannel subscribeToUserChats(Function() onChatsChanged) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return _client
        .channel('user_chats:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chats',
          callback: (payload) => onChatsChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onChatsChanged(),
        )
        .subscribe();
  }

  // Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  // Search users
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .or('full_name.ilike.%$query%,username.ilike.%$query%,email.ilike.%$query%')
          .limit(20);

      return response.map((json) => UserProfile.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to search users: $error');
    }
  }

  // Cleanup subscriptions
  Future<void> removeChannel(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}