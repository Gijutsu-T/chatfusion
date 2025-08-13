import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import './widgets/chat_input_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/typing_indicator_widget.dart';

class ChatDetail extends StatefulWidget {
  const ChatDetail({Key? key}) : super(key: key);

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  late ScrollController _scrollController;
  late TextEditingController _messageController;

  String? _chatId;
  String? _chatName;
  Chat? _chat;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isTyping = false;

  RealtimeChannel? _messagesSubscription;
  final int _pageSize = 50;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _messageController = TextEditingController();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _chatId = args['chatId'];
        _chatName = args['chatName'];
        _chat = args['chatModel'];
        _loadMessages();
        _subscribeToMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messagesSubscription?.unsubscribe();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_chatId == null) return;

    try {
      setState(() => _isLoading = true);

      final messages = await ChatService.instance.getChatMessages(
        _chatId!,
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _messages = messages.reversed.toList(); // Reverse to show oldest first
        _currentPage = 0;
        _hasMore = messages.length == _pageSize;
        _isLoading = false;
      });

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (error) {
      print('Error loading messages: $error');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages')),
      );
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMore || _chatId == null) return;

    try {
      setState(() => _isLoadingMore = true);

      final messages = await ChatService.instance.getChatMessages(
        _chatId!,
        limit: _pageSize,
        offset: (_currentPage + 1) * _pageSize,
      );

      setState(() {
        _messages.insertAll(0, messages.reversed); // Insert at beginning
        _currentPage++;
        _hasMore = messages.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (error) {
      print('Error loading more messages: $error');
      setState(() => _isLoadingMore = false);
    }
  }

  void _subscribeToMessages() {
    if (_chatId == null) return;

    _messagesSubscription = ChatService.instance.subscribeToChatMessages(
      _chatId!,
      (message) {
        setState(() {
          _messages.add(message);
        });

        // Auto-scroll to bottom for new messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty || _chatId == null) return;

    try {
      await ChatService.instance.sendMessage(
        chatId: _chatId!,
        content: content.trim(), fileUrl: null,
      );

      _messageController.clear();
    } catch (error) {
      print('Error sending message: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  Future<void> _sendImageMessage() async {
    if (_chatId == null) return;

    try {
      final fileData =
          await StorageService.instance.pickAndUploadImage(_chatId!);
      if (fileData == null) return;

      await ChatService.instance.sendMessage(
        chatId: _chatId!,
        content: '',
        messageType: 'image',
        fileUrl: fileData['file_url'],
        fileName: fileData['file_name'],
        fileSize: fileData['file_size'],
        fileType: fileData['file_type'],
      );
    } catch (error) {
      print('Error sending image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image')),
      );
    }
  }

  Future<void> _sendFileMessage() async {
    if (_chatId == null) return;

    try {
      final fileData =
          await StorageService.instance.pickAndUploadFile(_chatId!);
      if (fileData == null) return;

      await ChatService.instance.sendMessage(
        chatId: _chatId!,
        content: '',
        messageType: 'document',
        fileUrl: fileData['file_url'],
        fileName: fileData['file_name'],
        fileSize: fileData['file_size'],
        fileType: fileData['file_type'],
      );
    } catch (error) {
      print('Error sending file: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send file')),
      );
    }
  }

  Future<void> _editMessage(String messageId, String newContent) async {
    try {
      await ChatService.instance.updateMessage(messageId, newContent);
    } catch (error) {
      print('Error editing message: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit message')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await ChatService.instance.deleteMessage(messageId);
    } catch (error) {
      print('Error deleting message: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete message')),
      );
    }
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    try {
      await ChatService.instance.addReaction(messageId, emoji);
    } catch (error) {
      print('Error adding reaction: $error');
    }
  }

  void _onMessageLongPress(Message message) {
    final currentUserId = AuthService.instance.currentUser?.id;
    final isOwnMessage = message.senderId == currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.emoji_emotions_outlined),
            title: Text('Add Reaction'),
            onTap: () {
              Navigator.pop(context);
              _showReactionPicker(message.id);
            },
          ),
          ListTile(
            leading: Icon(Icons.reply_outlined),
            title: Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement reply functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reply functionality coming soon')),
              );
            },
          ),
          if (isOwnMessage) ...[
            ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(message);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outlined, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(message.id);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showReactionPicker(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a reaction',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['👍', '❤️', '😂', '😮', '😢', '😡'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _addReaction(messageId, emoji);
                  },
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Text(emoji, style: TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Message message) {
    final editController = TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Enter your message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editMessage(message.id, editController.text);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(messageId);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToGroupSettings() {
    if (_chat?.chatType == 'group') {
      Navigator.pushNamed(context, '/group-chat-settings', arguments: {
        'chatId': _chatId,
        'chatModel': _chat,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _navigateToGroupSettings,
          child: Row(
            children: [
              CircleAvatar(
                radius: 4.w,
                backgroundImage: NetworkImage(
                  _chat?.avatarUrl ??
                      "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _chatName ?? 'Chat',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_chat?.chatType == 'group')
                      Text(
                        '${_chat?.memberCount ?? 0} members',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/voice-video-call'),
            icon: CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _navigateToGroupSettings();
                  break;
                case 'mute':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mute functionality coming soon')),
                  );
                  break;
                case 'clear':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Clear chat functionality coming soon')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 2.w),
                    Text('Chat Info'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.volume_off_outlined),
                    SizedBox(width: 2.w),
                    Text('Mute Chat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_outlined),
                    SizedBox(width: 2.w),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(2.w),
                    itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && _isLoadingMore) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(2.w),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final messageIndex = _isLoadingMore ? index - 1 : index;
                      final message = _messages[messageIndex];
                      final currentUserId =
                          AuthService.instance.currentUser?.id;

                      return MessageBubbleWidget(
                        message: message,
                        isOwnMessage: message.senderId == currentUserId,
                        onLongPress: () => _onMessageLongPress(message),
                        onReaction: (emoji) => _addReaction(message.id, emoji),
                      );
                    },
                  ),
          ),
          if (_isTyping) TypingIndicatorWidget(userName: 'Someone'),
          ChatInputWidget(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onSendImage: _sendImageMessage,
            onSendFile: _sendFileMessage,
            onTyping: (isTyping) => setState(() => _isTyping = isTyping),
          ),
        ],
      ),
    );
  }
}