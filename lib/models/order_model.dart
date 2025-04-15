import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String clientId;
  final String? designerId;
  final String packageType;
  final String status; // pending, in_progress, completed, cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final List<String>? attachmentUrls;
  final String? clientFeedback;
  final int? clientRating;
  final double price;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? designBrief;
  
  OrderModel({
    required this.id,
    required this.clientId,
    this.designerId,
    required this.packageType,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.attachmentUrls,
    this.clientFeedback,
    this.clientRating,
    required this.price,
    this.paymentMethod,
    this.paymentStatus,
    this.designBrief,
  });
  
  // Create an OrderModel from a JSON object (e.g., from Firestore)
  factory OrderModel.fromJson(Map<String, dynamic> json, String documentId) {
    return OrderModel(
      id: documentId,
      clientId: json['clientId'] ?? '',
      designerId: json['designerId'],
      packageType: json['packageType'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : null,
      completedAt: json['completedAt'] != null 
          ? (json['completedAt'] as Timestamp).toDate() 
          : null,
      attachmentUrls: json['attachmentUrls'] != null 
          ? List<String>.from(json['attachmentUrls']) 
          : null,
      clientFeedback: json['clientFeedback'],
      clientRating: json['clientRating'],
      price: (json['price'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      designBrief: json['designBrief'],
    );
  }
  
  // Convert OrderModel to JSON for storing in Firestore
  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'designerId': designerId,
      'packageType': packageType,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completedAt': completedAt,
      'attachmentUrls': attachmentUrls,
      'clientFeedback': clientFeedback,
      'clientRating': clientRating,
      'price': price,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'designBrief': designBrief,
    };
  }
  
  // Create a copy of this OrderModel with updated fields
  OrderModel copyWith({
    String? id,
    String? clientId,
    String? designerId,
    String? packageType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? attachmentUrls,
    String? clientFeedback,
    int? clientRating,
    double? price,
    String? paymentMethod,
    String? paymentStatus,
    String? designBrief,
  }) {
    return OrderModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      designerId: designerId ?? this.designerId,
      packageType: packageType ?? this.packageType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      clientFeedback: clientFeedback ?? this.clientFeedback,
      clientRating: clientRating ?? this.clientRating,
      price: price ?? this.price,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      designBrief: designBrief ?? this.designBrief,
    );
  }
  
  // Formatted date string for display
  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt);
  
  // Formatted price string for display
  String get formattedPrice => NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(price);
  
  // Status display text
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'waiting':
        return 'Menunggu Proses';
      case 'review':
        return 'Review Desain';
      default:
        return status; // Mengembalikan status asli daripada 'Unknown'
    }
  }
}