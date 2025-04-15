import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../home/client_home_page.dart';
import '../home/designer_home_page.dart';
import '../order/order_history_page.dart';
import '../profile/profile_page.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  String _userId = '';
  String _userType = 'client';
  bool _isLoading = true;
  final TextEditingController _usernameController = TextEditingController();
  bool _isSearchingUser = false;
  
  // Add a stream subscription for unread message count
  late Stream<int> _unreadCountStream;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    if (mounted && userData != null) {
      setState(() {
        _userId = userData.uid;
        _userType = userData.userType;
        _isLoading = false;
      });
      
      // Initialize unread count stream after user data is loaded
      _unreadCountStream = _chatService.getUnreadMessageCount(_userId);
    }
  }

  Future<void> _showSearchUserDialog() async {
    _usernameController.clear();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Masukkan Nama Pengguna',
                hintText: 'Contoh: John Doe',
              ),
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchUser(),
            ),
            const SizedBox(height: 16),
            if (_isSearchingUser)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: _searchUser,
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _searchUser() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak boleh kosong')),
      );
      return;
    }
    
    setState(() {
      _isSearchingUser = true;
    });
    
    try {
      Navigator.pop(context);
      
      final user = await _chatService.searchUserByUsername(username);
      
      if (mounted) {
        setState(() {
          _isSearchingUser = false;
        });
        
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengguna tidak ditemukan')),
          );
          return;
        }
        
        if (user['uid'] == _userId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda tidak dapat chat dengan diri sendiri')),
          );
          return;
        }
        
        final chatId = await _chatService.createChat(
          user1Id: _userId, 
          user2Id: user['uid'],
        );
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailPage(
                chatId: chatId,
                otherUserId: user['uid'],
                otherUserName: user['name'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingUser = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Conversations', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _userId.isEmpty ? null : _showSearchUserDialog,
            tooltip: 'Cari pengguna untuk chat',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userId.isEmpty
              ? const Center(child: Text('Please login to see your chats'))
              : StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _chatService.getUserChats(_userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    
                    final chats = snapshot.data ?? [];
                    
                    if (chats.isEmpty) {
                      return const Center(
                        child: Text('No conversations yet'),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final otherUser = chat['otherUser'];
                        final lastMessage = chat['lastMessage'] ?? 'Start a conversation';
                        final lastMessageTime = chat['lastMessageTimestamp'] != null 
                            ? DateTime.parse(chat['lastMessageTimestamp'])
                            : null;
                        
                        return _buildChatItem(
                          name: otherUser['name'], 
                          profileImage: otherUser['photoURL'],
                          lastMessage: lastMessage,
                          lastMessageTime: lastMessageTime,
                          chatId: chat['id'], // Pass chatId
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  chatId: chat['id'],
                                  otherUserId: otherUser['uid'],
                                  otherUserName: otherUser['name'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2, 
        onTap: (index) {
          if (index != 2) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(
                builder: (_) {
                  if (index == 0) {
                    return _userType == 'designer'
                        ? const DesignerHomePage()
                        : const ClientHomePage();
                  } else if (index == 1) {
                    return const OrderHistoryPage();
                  } else {
                    return const ProfilePage();
                  }
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _userId.isEmpty ? null : _showSearchUserDialog,
        child: const Icon(Icons.chat),
        tooltip: 'Cari pengguna untuk chat',
      ),
    );
  }
  
  Widget _buildChatItem({
    required String name,
    String? profileImage,
    required String lastMessage,
    DateTime? lastMessageTime,
    required VoidCallback onTap,
    String? chatId,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueGrey,
        backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
        child: profileImage == null 
            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white))
            : null,
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: 90, // Fixed width for consistent layout
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (lastMessageTime != null)
              Text(
                '${lastMessageTime.hour}:${lastMessageTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(width: 8),
            if (chatId != null)
              StreamBuilder<int>(
                stream: _chatService.getUnreadMessageCount(_userId, chatId: chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Don't show anything while waiting for initial data
                    return const SizedBox(width: 26);
                  }
                  
                  final unreadCount = snapshot.data ?? 0;
                  
                  if (unreadCount <= 0) {
                    return const SizedBox(width: 26);
                  }
                  
                  return Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}