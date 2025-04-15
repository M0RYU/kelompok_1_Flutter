import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create a new order
  Future<String> createOrder({
    required String clientId,
    required String packageType,
    required double price,
    String? designBrief,
  }) async {
    try {
      final orderData = {
        'clientId': clientId,
        'packageType': packageType,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'price': price,
        'paymentStatus': 'pending',
        'designBrief': designBrief,
      };
      
      final docRef = await _firestore.collection('orders').add(orderData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: ${e.toString()}');
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }
  
  // Get a specific order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final docSnapshot = await _firestore.collection('orders').doc(orderId).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      return OrderModel.fromJson(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      debugPrint('Error getting order: ${e.toString()}');
      return null;
    }
  }
  
  // Get orders for a client - with fallback strategy
  Stream<List<OrderModel>> getClientOrders(String clientId) {
    try {
      debugPrint('Attempting to query client orders for clientId: $clientId');
      
      // First attempt with compound query (with index)
      return _firestore
          .collection('orders')
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('❌ CLIENT ORDERS COMPOUND QUERY ERROR: $error');
            debugPrint('Falling back to simple query without ordering...');
            
            // Fallback to simpler query without ordering
            return _firestore
                .collection('orders')
                .where('clientId', isEqualTo: clientId)
                .snapshots();
          })
          .map((snapshot) {
            debugPrint('Successfully got ${snapshot.docs.length} client orders');
            final orders = snapshot.docs
                .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
                .toList();
            
            // Manually sort the results if using fallback query
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return orders;
          });
    } catch (e) {
      debugPrint('❌ Error getting client orders: ${e.toString()}');
      return Stream.value([]);
    }
  }
  
  // Get orders for a designer - with fallback strategy
  Stream<List<OrderModel>> getDesignerOrders(String designerId) {
    try {
      debugPrint('Attempting to query designer orders for designerId: $designerId');
      
      // First attempt with compound query (with index)
      return _firestore
          .collection('orders')
          .where('designerId', isEqualTo: designerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('❌ DESIGNER ORDERS COMPOUND QUERY ERROR: $error');
            debugPrint('Falling back to simple query without ordering...');
            
            // Fallback to simpler query without ordering
            return _firestore
                .collection('orders')
                .where('designerId', isEqualTo: designerId)
                .snapshots();
          })
          .map((snapshot) {
            debugPrint('Successfully got ${snapshot.docs.length} designer orders');
            final orders = snapshot.docs
                .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
                .toList();
            
            // Manually sort the results if using fallback query
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return orders;
          });
    } catch (e) {
      debugPrint('❌ Error getting designer orders: ${e.toString()}');
      return Stream.value([]);
    }
  }
  
  // Get available orders for designers to pick up - with fallback strategy
  Stream<List<OrderModel>> getAvailableOrders() {
    try {
      debugPrint('Attempting to query available orders');
      
      // First attempt with compound query (with index)
      return _firestore
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .where('designerId', isNull: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('❌ AVAILABLE ORDERS COMPOUND QUERY ERROR: $error');
            debugPrint('Falling back to simple query without ordering...');
            
            // Fallback to simpler query without ordering
            return _firestore
                .collection('orders')
                .where('status', isEqualTo: 'pending')
                .where('designerId', isNull: true)
                .snapshots();
          })
          .map((snapshot) {
            debugPrint('Successfully got ${snapshot.docs.length} available orders');
            final orders = snapshot.docs
                .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
                .toList();
            
            // Manually sort the results if using fallback query
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return orders;
          });
    } catch (e) {
      debugPrint('❌ Error getting available orders: ${e.toString()}');
      return Stream.value([]);
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order status: ${e.toString()}');
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }
  
  // Assign order to a designer
  Future<void> assignOrderToDesigner(String orderId, String designerId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'designerId': designerId,
        'status': 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error assigning order: ${e.toString()}');
      throw Exception('Failed to assign order: ${e.toString()}');
    }
  }
  
  // Add client feedback and rating
  Future<void> addClientFeedback(String orderId, String feedback, int rating) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'clientFeedback': feedback,
        'clientRating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding feedback: ${e.toString()}');
      throw Exception('Failed to add feedback: ${e.toString()}');
    }
  }
  
  // Add attachment URLs to order
  Future<void> addAttachments(String orderId, List<String> attachmentUrls) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'attachmentUrls': FieldValue.arrayUnion(attachmentUrls),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding attachments: ${e.toString()}');
      throw Exception('Failed to add attachments: ${e.toString()}');
    }
  }
  
  // Update payment status
  Future<void> updatePaymentStatus(String orderId, String status, String paymentMethod) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'paymentStatus': status,
        'paymentMethod': paymentMethod,
        'paymentDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating payment status: ${e.toString()}');
      throw Exception('Failed to update payment status: ${e.toString()}');
    }
  }
}

