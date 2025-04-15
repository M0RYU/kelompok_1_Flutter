import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../models/message_model.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatDetailPage({
    Key? key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  String _userId = '';
  bool _isSending = false;
  File? _imageFile;
  StreamSubscription<List<MessageModel>>? _messageReadListener;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Add post frame callback to scroll to bottom when messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  
  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    if (mounted && userData != null) {
      setState(() {
        _userId = userData.uid;
      });
      
      // Mark messages as read when user opens the chat
      _markMessagesAsRead();
    }
  }
  
  Future<void> _markMessagesAsRead() async {
    if (_userId.isNotEmpty) {
      try {
        // Don't mark messages immediately on page load
        // Instead, we'll mark messages as read when they appear on screen
        // This ensures accurate unread counts
        await _chatService.markMessagesAsRead(widget.chatId, _userId);
        
        // Set up a listener to mark new messages as read when they're received
        _messageReadListener = _chatService.getChatMessages(widget.chatId).listen((messages) {
          if (messages.isNotEmpty && mounted) {
            // Only mark messages as read if the user is actively viewing this chat
            _chatService.markMessagesAsRead(widget.chatId, _userId);
          }
        });
      } catch (e) {
        debugPrint('Error marking messages as read: ${e.toString()}');
      }
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }
  
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    
    if ((text.isEmpty && _imageFile == null) || _userId.isEmpty) {
      return;
    }
    
    setState(() {
      _isSending = true;
    });
    
    try {
      // In a real app, you would upload the image to storage first
      // and then store the URL in the message
      String? attachmentUrl;
      String? attachmentType;
      
      if (_imageFile != null) {
        // This would be a real upload in a full app
        attachmentUrl = 'https://example.com/mock_image_url.jpg';
        attachmentType = 'image';
      }
      
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: _userId,
        content: text,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
      
      _messageController.clear();
      setState(() {
        _imageFile = null;
      });
      
      // Scroll to the bottom after sending a new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Cancel the message read listener when leaving the chat
    _messageReadListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
      body: _userId.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages Area
                Expanded(
                  child: StreamBuilder<List<MessageModel>>(
                    stream: _chatService.getChatMessages(widget.chatId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      
                      final messages = snapshot.data ?? [];
                      
                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('No messages yet'),
                        );
                      }
                      
                      // Group messages by date
                      final messagesByDate = <String, List<MessageModel>>{};
                      for (final message in messages) {
                        final date = message.formattedDate;
                        messagesByDate.putIfAbsent(date, () => []);
                        messagesByDate[date]!.add(message);
                      }

                      final sortedDates = messagesByDate.keys.toList()
                        ..sort((a, b) {
                          final dateA = DateFormat('dd MMM yyyy').parse(a);
                          final dateB = DateFormat('dd MMM yyyy').parse(b);
                          return dateA.compareTo(dateB);
                        });
                      
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: sortedDates.length,
                        itemBuilder: (context, dateIndex) {
                          final date = sortedDates[dateIndex];
                          final messagesForDate = messagesByDate[date]!;
                          
                          return Column(
                            children: [
                              // Date Header
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Messages for this date
                              ...messagesForDate.map((message) => 
                                _buildMessageBubble(
                                  message: message,
                                  isMe: message.senderId == _userId,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                
                // Selected Image Preview
                if (_imageFile != null)
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Stack(
                      children: [
                        Center(
                          child: Image.file(
                            _imageFile!,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageFile = null;
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Message Input Area
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Attachment Button
                      IconButton(
                        icon: const Icon(Icons.photo),
                        onPressed: _pickImage,
                      ),
                      
                      // Text Input Field
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                        ),
                      ),
                      
                      // Send Button
                      IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildMessageBubble({
    required MessageModel message,
    required bool isMe,
  }) {
    final radius = Radius.circular(12);
    
    return Container(
      margin: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 80 : 16,
        right: isMe ? 16 : 80,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          message.attachmentUrl != null ? 4 : 12,
          message.attachmentUrl != null ? 4 : 8,
          12,
          8,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[400] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: isMe ? radius : Radius.zero,
            bottomRight: isMe ? Radius.zero : radius,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attachment (if any)
            if (message.attachmentUrl != null && message.attachmentType == 'image')
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                  maxHeight: 200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.attachmentUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        width: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
              ),
            
            // Text Message (if any)
            if (message.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: message.attachmentUrl != null ? 8 : 0,
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ),
              
            // Timestamp
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  message.formattedTime,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white.withOpacity(0.7) : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}