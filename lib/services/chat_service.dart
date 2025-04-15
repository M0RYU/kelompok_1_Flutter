import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create a new chat between two users
  Future<String> createChat({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      // Check if a chat between these users already exists
      final existingChatQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContainsAny: [user1Id, user2Id])
          .get();
      
      for (final doc in existingChatQuery.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(user1Id) && participants.contains(user2Id)) {
          return doc.id;
        }
      }
      
      // Create a new chat
      final chatData = {
        'participants': [user1Id, user2Id],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTimestamp': null,
      };
      
      final docRef = await _firestore.collection('chats').add(chatData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating chat: ${e.toString()}');
      throw Exception('Failed to create chat: ${e.toString()}');
    }
  }
  
  // Send a message in a chat
  Future<String> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    try {
      final messageData = {
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
        'isRead': false,
      };
      
      // Add the message to the messages collection
      final docRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);
      
      // Update the chat document with the last message info
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageSenderId': senderId,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      debugPrint('Error sending message: ${e.toString()}');
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }
  
  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      debugPrint('Error getting chat messages: ${e.toString()}');
      return Stream.value([]);
    }
  }
  
  // Get all chats for a user
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    try {
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .snapshots()
          .asyncMap((snapshot) async {
        final chats = <Map<String, dynamic>>[];
        
        for (final doc in snapshot.docs) {
          final chatData = doc.data();
          final participants = List<String>.from(chatData['participants']);
          
          // Find the other user's ID
          final otherUserId = participants.firstWhere(
            (id) => id != userId,
            orElse: () => userId,
          );
          
          // Get the other user's data
          final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
          
          if (otherUserDoc.exists) {
            final otherUserData = otherUserDoc.data()!;
            
            chats.add({
              'id': doc.id,
              'otherUser': {
                'uid': otherUserId,
                'name': otherUserData['name'] ?? 'User',
                'photoURL': otherUserData['photoURL'],
              },
              'lastMessage': chatData['lastMessage'],
              'lastMessageTimestamp': chatData['lastMessageTimestamp']?.toDate()?.toIso8601String(),
              'updatedAt': chatData['updatedAt']?.toDate(),
            });
          }
        }
        
        // Sort chats by updatedAt manually instead of using Firestore orderBy
        chats.sort((a, b) {
          final DateTime? dateA = a['updatedAt'];
          final DateTime? dateB = b['updatedAt'];
          
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // Null values go last
          if (dateB == null) return -1;
          
          return dateB.compareTo(dateA); // Descending order (newest first)
        });
        
        return chats;
      });
    } catch (e) {
      debugPrint('Error getting user chats: ${e.toString()}');
      return Stream.value([]);
    }
  }
  
  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();
      
      // If there are no unread messages, avoid unnecessary operations
      if (messagesQuery.docs.isEmpty) {
        return;
      }
      
      final batch = _firestore.batch();
      
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as read: ${e.toString()}');
      throw Exception('Failed to mark messages as read: ${e.toString()}');
    }
  }
  
  // Get unread message count for a user
  Stream<int> getUnreadMessageCount(String userId, {String? chatId}) {
    try {
      if (chatId != null) {
        // Get unread count for a specific chat
        return _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .where('senderId', isNotEqualTo: userId)
            .snapshots()
            .map((snapshot) => snapshot.docs.length);
      } else {
        // Get total unread count across all chats
        return _firestore
            .collection('chats')
            .where('participants', arrayContains: userId)
            .snapshots()
            .asyncMap((snapshot) async {
              int count = 0;
              
              for (final doc in snapshot.docs) {
                final messagesQuery = await _firestore
                    .collection('chats')
                    .doc(doc.id)
                    .collection('messages')
                    .where('isRead', isEqualTo: false)
                    .where('senderId', isNotEqualTo: userId)
                    .count()
                    .get();
                
                // Tambahkan null check untuk mengatasi tipe data int?
                count += messagesQuery.count ?? 0;
              }
              
              return count;
            });
      }
    } catch (e) {
      debugPrint('Error getting unread message count: ${e.toString()}');
      return Stream.value(0);
    }
  }

  // Search for a user by username
  Future<Map<String, dynamic>?> searchUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: username)  // Mengubah 'username' menjadi 'name'
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();
        
        return {
          'uid': userDoc.id,
          'name': userData['name'] ?? 'User',
          'username': userData['name'],  // Menggunakan name sebagai username
          'photoURL': userData['photoURL'],
          'userType': userData['userType'] ?? 'client',
        };
      }
      
      return null; // User not found
    } catch (e) {
      debugPrint('Error searching user by username: ${e.toString()}');
      throw Exception('Failed to search user: ${e.toString()}');
    }
  }
}