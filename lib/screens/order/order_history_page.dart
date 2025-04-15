import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../home/client_home_page.dart';
import '../home/designer_home_page.dart';
import '../chat/chat_list_page.dart';
import '../profile/profile_page.dart';
import '../order/order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String _filterStatus = 'Semua';
  late String _userType;
  bool _isLoading = true;
  String? _userId;
  Stream<List<OrderModel>>? _ordersStream;
  final OrderService _orderService = OrderService();
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    if (!mounted) return;
    
    setState(() {
      _userType = userData?.userType ?? 'client';
      _userId = userData?.uid; // Menggunakan uid bukan id
      _isLoading = false;
    });
    
    _setupOrdersStream();
  }
  
  void _setupOrdersStream() {
    if (_userId == null) return;
    
    setState(() {
      if (_userType == 'designer') {
        _ordersStream = _orderService.getDesignerOrders(_userId!);
      } else {
        _ordersStream = _orderService.getClientOrders(_userId!);
      }
    });
  }
  
  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_filterStatus == 'Semua') {
      return orders;
    }
    final statusMap = {
      'Selesai': 'completed',
      'Dalam Proses': 'in_progress',
      'Menunggu': 'pending',
      'Dibatalkan': 'cancelled',
      'Menunggu Proses': 'waiting',
      'Review Desain': 'review',
    };
    return orders.where((o) => o.status == statusMap[_filterStatus]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Riwayat Pemesanan', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _filterStatus,
              items: const [
                DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                DropdownMenuItem(value: 'Dalam Proses', child: Text('Dalam Proses')),
                DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                DropdownMenuItem(value: 'Menunggu Proses', child: Text('Menunggu Proses')),
                DropdownMenuItem(value: 'Review Desain', child: Text('Review Desain')),
                DropdownMenuItem(value: 'Dibatalkan', child: Text('Dibatalkan')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filterStatus = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userId == null
              ? const Center(child: Text('Anda harus login untuk melihat riwayat pemesanan'))
              : _buildOrdersList(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            if (index == 0) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (_) => _userType == 'designer'
                      ? const DesignerHomePage()
                      : const ClientHomePage(),
                )
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (index == 2) return const ChatListPage();
                    return const ProfilePage();
                  },
                ),
              );
            }
          }
        }
      ),
    );
  }

  Widget _buildOrdersList() {
    return _ordersStream == null
        ? const Center(child: Text('Tidak ada riwayat pesanan'))
        : StreamBuilder<List<OrderModel>>(
            stream: _ordersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final orders = snapshot.data ?? [];
              
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _userType == 'designer'
                            ? 'Belum ada pesanan yang ditugaskan kepada Anda'
                            : 'Anda belum memiliki riwayat pemesanan',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              final filteredOrders = _filterOrders(orders);
              
              return filteredOrders.isEmpty
                  ? Center(child: Text('Tidak ada pesanan dengan status $_filterStatus'))
                  : ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
                    );
            },
          );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusColors = {
      'completed': Colors.green,
      'in_progress': Colors.blue,
      'pending': Colors.amber,
      'cancelled': Colors.red,
    };
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.design_services, color: Colors.grey),
        ),
        title: Text(
          order.packageType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${order.id}'),
            Text('Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(order.createdAt)}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColors[order.status] ?? Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                order.statusDisplay,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              order.formattedPrice,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          // Navigate to order details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(orderId: order.id),
            ),
          ).then((_) {
            // Refresh orders when returning from details page
            _setupOrdersStream();
          });
        },
      ),
    );
  }
}