import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../home/client_home_page.dart';
import '../order/order_history_page.dart';

class OrderSuccessPage extends StatelessWidget {
  final String orderId;
  final String packageType;
  final double price;
  final String paymentMethod;
  
  const OrderSuccessPage({
    Key? key,
    required this.orderId,
    required this.packageType,
    required this.price,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(now);
    
    // Create a controller for taking screenshot of the receipt
    final screenshotController = ScreenshotController();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Order Success', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Success Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Success Message
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Your order has been successfully placed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Order ID: $orderId',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Receipt
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Receipt Header
                          const Center(
                            child: Text(
                              'PAYMENT RECEIPT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          
                          // Order Details
                          _buildReceiptRow('Date', formattedDate),
                          _buildReceiptRow('Order ID', orderId),
                          _buildReceiptRow('Package', packageType),
                          _buildReceiptRow('Payment Method', paymentMethod),
                          _buildReceiptRow('Status', 'Paid'),
                          
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          
                          // Total
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  formatter.format(price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // QR Code
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: CustomPaint(
                                    painter: ReceiptQRPainter(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thank you for your order!',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Download Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _captureAndSaveReceipt(screenshotController),
                          icon: const Icon(Icons.download),
                          label: const Text('Download Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const ClientHomePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Back to Home'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('View My Orders'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _captureAndSaveReceipt(ScreenshotController screenshotController) async {
    try {
      // Capture the receipt
      final Uint8List? imageBytes = await screenshotController.capture();
      
      if (imageBytes != null) {
        // Get temporary directory to save the file
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/receipt_$orderId.png';
        
        // Save the file
        final File file = File(imagePath);
        await file.writeAsBytes(imageBytes);
        
        // Share the file
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Payment receipt for your order $orderId',
        );
      }
    } catch (e) {
      print('Error saving receipt: $e');
    }
  }
}

// A painter to draw a receipt QR code
class ReceiptQRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 15;
    final random = math.Random(12); // Fixed seed for consistent look

    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        // Always draw the corners as fixed patterns
        if ((i < 5 && j < 5) || // Top-left corner
            (i < 5 && j > 9) || // Top-right corner
            (i > 9 && j < 5)) { // Bottom-left corner
          
          // Create the corner patterns
          if (i == 0 || i == 4 || j == 0 || j == 4 ||
              (i >= 1 && i <= 3 && j >= 1 && j <= 3 && i == j)) {
            canvas.drawRect(
              Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize),
              paint,
            );
          }
        } else if (random.nextBool() && random.nextBool()) { // Random fill for the rest with less density
          canvas.drawRect(
            Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}