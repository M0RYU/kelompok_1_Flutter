import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentType; // image, file, etc.
  final bool isRead;
  
  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.attachmentUrl,
    this.attachmentType,
    this.isRead = false,
  });
  
  // Create a MessageModel from a JSON object (e.g., from Firestore)
  factory MessageModel.fromJson(Map<String, dynamic> json, String documentId) {
    return MessageModel(
      id: documentId,
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? (json['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
      attachmentUrl: json['attachmentUrl'],
      attachmentType: json['attachmentType'],
      isRead: json['isRead'] ?? false,
    );
  }
  
  // Convert MessageModel to JSON for storing in Firestore
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'isRead': isRead,
    };
  }
  
  // Create a copy of this MessageModel with updated fields
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    String? attachmentUrl,
    String? attachmentType,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      isRead: isRead ?? this.isRead,
    );
  }
  
  // Formatted date string for display (e.g. "24 Apr 2024")
  String get formattedDate => DateFormat('dd MMM yyyy').format(timestamp);
  
  // Formatted time string for display (e.g. "14:30")
  String get formattedTime => DateFormat('HH:mm').format(timestamp);
}