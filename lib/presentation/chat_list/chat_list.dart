import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import './widgets/chat_item_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/tab_bar_widget.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  bool _isSearchActive = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredChats = [];

  // Real data from Supabase
  List<Chat> _allChats = [];
  Map<String, Message?> _lastMessages = {};
  Map<String, UserProfile?> _chatUsers = {};
  Map<String, int> _unreadCounts = {};
  bool _isLoading = true;

  RealtimeChannel? _chatsSubscription;

  final List<String> _tabs = ['Chats', 'Groups', 'Channels'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterChatsByTab();
      }
    });

    _loadChats();
    _subscribeToChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _chatsSubscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadChats() async {
    try {
      setState(() => _isLoading = true);

      // Update user activity
      await ChatService.instance.updateUserActivity();

      // Load user chats
      _allChats = await ChatService.instance.getUserChats();

      // Load additional data for each chat
      await _loadChatDetails();

      _filterChatsByTab();
    } catch (error) {
      print('Error loading chats: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chats')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChatDetails() async {
    for (final chat in _allChats) {
      try {
        // Get last message
        final messages =
            await ChatService.instance.getChatMessages(chat.id, limit: 1);
        if (messages.isNotEmpty) {
          _lastMessages[chat.id] = messages.first;
        }

        // For direct chats, get the other user's profile
        if (chat.chatType == 'direct') {
          final members = await ChatService.instance.getChatMembers(chat.id);
          final currentUserId = AuthService.instance.currentUser?.id;
          final otherMember = members.firstWhere(
            (member) => member.userId != currentUserId,
            orElse: () => members.first,
          );

          if (otherMember.userProfile != null) {
            _chatUsers[chat.id] = otherMember.userProfile;
          } else {
            final profile =
                await ChatService.instance.getUserProfile(otherMember.userId);
            _chatUsers[chat.id] = profile;
          }
        }

        // TODO: Calculate unread count (requires message_status table implementation)
        _unreadCounts[chat.id] = 0;
      } catch (error) {
        print('Error loading details for chat ${chat.id}: $error');
      }
    }
  }

  void _subscribeToChats() {
    _chatsSubscription = ChatService.instance.subscribeToUserChats(() {
      _loadChats();
    });
  }

  void _filterChatsByTab() {
    setState(() {
      List<Chat> filteredChats = [];

      switch (_tabController.index) {
        case 0: // Chats
          filteredChats =
              _allChats.where((chat) => chat.chatType == 'direct').toList();
          break;
        case 1: // Groups
          filteredChats =
              _allChats.where((chat) => chat.chatType == 'group').toList();
          break;
        case 2: // Channels
          filteredChats =
              _allChats.where((chat) => chat.chatType == 'channel').toList();
          break;
        default:
          filteredChats = _allChats;
      }

      // Convert to display format
      _filteredChats =
          filteredChats.map((chat) => _chatToDisplayFormat(chat)).toList();
      _applySearchFilter();
    });
  }

  Map<String, dynamic> _chatToDisplayFormat(Chat chat) {
    final lastMessage = _lastMessages[chat.id];
    final chatUser = _chatUsers[chat.id];
    final unreadCount = _unreadCounts[chat.id] ?? 0;

    String displayName = chat.name ?? 'Unknown Chat';
    String? avatarUrl = chat.avatarUrl;

    // For direct chats, use other user's info
    if (chat.chatType == 'direct' && chatUser != null) {
      displayName = chatUser.fullName;
      avatarUrl = chatUser.avatarUrl;
    }

    return {
      "id": chat.id,
      "name": displayName,
      "avatar": avatarUrl ??
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      "lastMessage": lastMessage?.content ?? "No messages yet",
      "lastMessageType": lastMessage?.messageType ?? "text",
      "timestamp": lastMessage?.createdAt ?? chat.createdAt,
      "unreadCount": unreadCount,
      "isOnline":
          chat.chatType == 'direct' ? (chatUser?.isOnline ?? false) : false,
      "isPinned": chat.isPinned,
      "isGroup": chat.chatType == 'group',
      "memberCount": chat.memberCount,
      "hasFailedMessage": false,
      "isTyping": false,
      "chatModel": chat, // Store the original model
    };
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _filteredChats = _filteredChats.where((chat) {
        final name = (chat['name'] ?? '').toString().toLowerCase();
        final message = (chat['lastMessage'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || message.contains(query);
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearchActive = query.isNotEmpty;
    });
    _filterChatsByTab();
  }

  void _onSearchClear() {
    setState(() {
      _searchQuery = '';
      _isSearchActive = false;
    });
    _filterChatsByTab();
  }

  Future<void> _onRefresh() async {
    await _loadChats();
    HapticFeedback.lightImpact();
  }

  void _navigateToChat(Map<String, dynamic> chatData) {
    Navigator.pushNamed(context, '/chat-detail', arguments: {
      'chatId': chatData['id'],
      'chatName': chatData['name'],
      'chatModel': chatData['chatModel'],
    });
  }

  void _navigateToNewChat() {
    Navigator.pushNamed(context, '/user-profile');
  }

  void _archiveChat(Map<String, dynamic> chatData) async {
    try {
      // TODO: Implement archive functionality in ChatService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archive functionality coming soon')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive chat')),
      );
    }
  }

  void _deleteChat(Map<String, dynamic> chatData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat'),
        content: Text(
            'Are you sure you want to delete this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delete functionality coming soon')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorLight),
            ),
          ),
        ],
      ),
    );
  }

  void _pinChat(Map<String, dynamic> chatData) async {
    try {
      // TODO: Implement pin functionality in ChatService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pin functionality coming soon')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pin chat')),
      );
    }
  }

  void _muteChat(Map<String, dynamic> chatData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mute functionality coming soon')),
    );
  }

  void _markAsRead(Map<String, dynamic> chatData) {
    setState(() {
      final chatIndex =
          _filteredChats.indexWhere((chat) => chat['id'] == chatData['id']);
      if (chatIndex != -1) {
        _filteredChats[chatIndex]['unreadCount'] = 0;
        _unreadCounts[chatData['id']] = 0;
      }
    });
  }

  void _blockUser(Map<String, dynamic> chatData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure you want to block ${chatData['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Block functionality coming soon')),
              );
            },
            child: Text(
              'Block',
              style: TextStyle(color: AppTheme.errorLight),
            ),
          ),
        ],
      ),
    );
  }

  void _exportChat(Map<String, dynamic> chatData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _handleSignOut() async {
    try {
      await ChatService.instance.setUserOffline();
      await AuthService.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ChatFusion',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/user-profile');
                  break;
                case 'logout':
                  _handleSignOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.account_circle_outlined),
                    SizedBox(width: 2.w),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined),
                    SizedBox(width: 2.w),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'account_circle',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(12.h),
          child: Column(
            children: [
              SearchBarWidget(
                onSearchChanged: _onSearchChanged,
                onSearchClear: _onSearchClear,
                isSearchActive: _isSearchActive,
              ),
              TabBarWidget(
                tabController: _tabController,
                tabs: _tabs,
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildChatList()).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewChat,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 4,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 6.w,
        ),
      ),
    );
  }

  Widget _buildChatList() {
    if (_filteredChats.isEmpty) {
      return EmptyStateWidget(
        onStartChat: _navigateToNewChat,
      );
    }

    // Separate pinned and regular chats
    final pinnedChats =
        _filteredChats.where((chat) => chat['isPinned'] ?? false).toList();
    final regularChats =
        _filteredChats.where((chat) => !(chat['isPinned'] ?? false)).toList();

    // Sort by timestamp (most recent first)
    pinnedChats.sort((a, b) =>
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    regularChats.sort((a, b) =>
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    final allSortedChats = [...pinnedChats, ...regularChats];

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      child: ListView.builder(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: allSortedChats.length +
            (pinnedChats.isNotEmpty && regularChats.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          // Add divider between pinned and regular chats
          if (pinnedChats.isNotEmpty &&
              regularChats.isNotEmpty &&
              index == pinnedChats.length) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppTheme.lightTheme.dividerColor,
                      thickness: 0.5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text(
                      'All Chats',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppTheme.lightTheme.dividerColor,
                      thickness: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }

          final chatIndex = index > pinnedChats.length ? index - 1 : index;
          final chatData = allSortedChats[chatIndex];

          return ChatItemWidget(
            chatData: chatData,
            onTap: () => _navigateToChat(chatData),
            onArchive: () => _archiveChat(chatData),
            onPin: () => _pinChat(chatData),
            onMute: () => _muteChat(chatData),
            onDelete: () => _deleteChat(chatData),
            onMarkAsRead: () => _markAsRead(chatData),
            onBlock: () => _blockUser(chatData),
            onExport: () => _exportChat(chatData),
          );
        },
      ),
    );
  }
}
