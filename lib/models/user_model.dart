import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? photoURL;
  final String userType; // 'client' or 'designer'
  final String? address;
  final String? nik; // National ID number (for designers)
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.photoURL,
    required this.userType,
    this.address,
    this.nik,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a UserModel from a JSON object (e.g., from Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      uid: documentId,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoURL: json['photoURL'],
      userType: json['userType'] ?? 'client',
      address: json['address'],
      nik: json['nik'],
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  // Convert UserModel to JSON for storing in Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'photoURL': photoURL,
      'userType': userType,
      'address': address,
      'nik': nik,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of this UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? photoURL,
    String? userType,
    String? address,
    String? nik,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      userType: userType ?? this.userType,
      address: address ?? this.address,
      nik: nik ?? this.nik,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}