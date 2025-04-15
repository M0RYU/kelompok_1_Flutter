import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:path/path.dart' as path;
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/azure_storage_service.dart';
import 'order_success_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStepperPage extends StatefulWidget {
  final String packageType;
  final double price;
  final String packageDescription;
  
  const OrderStepperPage({
    Key? key,
    required this.packageType,
    required this.price,
    required this.packageDescription,
  }) : super(key: key);

  @override
  State<OrderStepperPage> createState() => _OrderStepperPageState();
}

class _OrderStepperPageState extends State<OrderStepperPage> {
  final OrderService _orderService = OrderService();
  final AzureStorageService _azureStorage = AzureStorageService();
  int _step = 0;
  bool _isLoading = false;
  String? _userId;
  final _pageController = PageController();
  String? _orderId;
  
  // Form controllers
  final namaUsahaController = TextEditingController();
  final jenisUsahaController = TextEditingController();
  final alamatUsahaController = TextEditingController();
  final teleponUsahaController = TextEditingController();
  final deskripsiUsahaController = TextEditingController();
  final temaController = TextEditingController();
  final warnaController = TextEditingController();
  final ukuranController = TextEditingController();
  final kataKataController = TextEditingController();
  final catatanController = TextEditingController();
  final noRekeningController = TextEditingController();
  
  // File uploads
  List<PlatformFile> _selectedFiles = [];
  String _selectedPaymentMethod = '';
  bool _paymentComplete = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    namaUsahaController.dispose();
    jenisUsahaController.dispose();
    alamatUsahaController.dispose();
    teleponUsahaController.dispose();
    deskripsiUsahaController.dispose();
    temaController.dispose();
    warnaController.dispose();
    ukuranController.dispose();
    kataKataController.dispose();
    catatanController.dispose();
    noRekeningController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    if (mounted && userData != null) {
      setState(() {
        _userId = userData.uid;
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Changed from FileType.image to allow any file type
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          // Append to existing files rather than replacing
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: ${e.toString()}')),
      );
    }
  }

  Future<List<String>> _uploadFilesToAzure() async {
    List<String> uploadedUrls = [];
    
    try {
      if (_userId == null || _orderId == null) {
        throw Exception('User ID or Order ID is null');
      }
      
      List<File> files = [];
      for (var file in _selectedFiles) {
        if (file.path != null) {
          files.add(File(file.path!));
        }
      }
      
      if (files.isNotEmpty) {
        uploadedUrls = await _azureStorage.uploadFiles(files, _userId!, _orderId!);
      }
      
      return uploadedUrls;
    } catch (e) {
      print('Error uploading files: ${e.toString()}');
      throw e;
    }
  }

  Future<void> _submitOrder() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    if (_selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create design brief from form inputs
      final designBrief = {
        'businessName': namaUsahaController.text,
        'businessType': jenisUsahaController.text,
        'businessAddress': alamatUsahaController.text,
        'businessPhone': teleponUsahaController.text,
        'businessDescription': deskripsiUsahaController.text,
        'designTheme': temaController.text,
        'designColor': warnaController.text,
        'designSize': ukuranController.text,
        'designText': kataKataController.text,
        'designNotes': catatanController.text,
        'paymentMethod': _selectedPaymentMethod,
      };

      // Create the order
      final orderId = await _orderService.createOrder(
        clientId: _userId!,
        packageType: widget.packageType,
        price: widget.price,
        designBrief: designBrief.toString(),
      );
      
      _orderId = orderId;
      
      // Upload attachments if there are any
      if (_selectedFiles.isNotEmpty) {
        // Upload files to Azure Blob Storage and get download URLs
        final attachmentUrls = await _uploadFilesToAzure();
        if (attachmentUrls.isNotEmpty) {
          await _orderService.addAttachments(orderId, attachmentUrls);
        }
      }
      
      // Assign this order to the designer with the fewest orders
      await _assignToDesignerWithLeastOrders(orderId);
      
      // Update payment status
      await _orderService.updatePaymentStatus(orderId, 'completed', _selectedPaymentMethod);
      
      // Set order status to 'waiting' instead of 'pending' after payment completed
      await _orderService.updateOrderStatus(orderId, 'waiting');

      if (!mounted) return;

      setState(() {
        _paymentComplete = true;
        _isLoading = false;
      });

      // Navigate to the success page instead of popping
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            orderId: orderId,
            packageType: widget.packageType,
            price: widget.price,
            paymentMethod: _selectedPaymentMethod,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _assignToDesignerWithLeastOrders(String orderId) async {
    try {
      // Get a reference to the Firestore database
      final firestore = FirebaseFirestore.instance;
      
      // Fetch all users with type 'designer'
      final designerSnapshot = await firestore
          .collection('users')
          .where('userType', isEqualTo: 'designer')
          .get();
      
      if (designerSnapshot.docs.isEmpty) {
        throw Exception('No designers available in the system');
      }
      
      // List to store designers with their order counts
      List<Map<String, dynamic>> designersWithOrders = [];
      
      // For each designer, count their current orders
      for (var designerDoc in designerSnapshot.docs) {
        final designerId = designerDoc.id;
        
        // Count orders assigned to this designer that are not completed or cancelled
        final orderSnapshot = await firestore
            .collection('orders')
            .where('designerId', isEqualTo: designerId)
            .where('status', whereIn: ['pending', 'in_progress'])
            .get();
        
        final orderCount = orderSnapshot.docs.length;
        
        // Add to our list
        designersWithOrders.add({
          'id': designerId, 
          'orderCount': orderCount,
          'name': designerDoc.data()['name'] ?? 'Unknown Designer'
        });
      }
      
      // Sort designers by order count (ascending)
      designersWithOrders.sort((a, b) => 
          (a['orderCount'] as int).compareTo(b['orderCount'] as int));
      
      // Get the designer with the lowest number of orders
      if (designersWithOrders.isNotEmpty) {
        final designerId = designersWithOrders.first['id'] as String;
        
        // Assign the order to this designer
        await _orderService.assignOrderToDesigner(orderId, designerId);
        
        debugPrint('Order $orderId assigned to designer $designerId with ${designersWithOrders.first['orderCount']} existing orders');
      } else {
        throw Exception('Failed to find available designers');
      }
    } catch (e) {
      debugPrint('Error assigning order to designer: ${e.toString()}');
      // If something goes wrong, assign to an admin or generate an alert
      throw Exception('Failed to assign order: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          'Order ${widget.packageType}',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Step indicator - simplified with numbers stretching from left to right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _step >= index ? Colors.blue : Colors.grey,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Progress line connecting the step indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Stack(
              children: [
                // Gray background line
                Container(
                  height: 2,
                  color: Colors.grey,
                ),
                // Blue progress line
                Container(
                  height: 2,
                  width: _step == 0 
                      ? 0 
                      : _step == 1 
                          ? MediaQuery.of(context).size.width * 0.3
                          : _step == 2 
                              ? MediaQuery.of(context).size.width * 0.6
                              : MediaQuery.of(context).size.width - 64,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                buildFormStep1(),
                buildFormStep2(),
                buildSummaryStep(),
                buildPaymentStep(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_step > 0)
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: FloatingActionButton(
                heroTag: 'back',
                mini: true,
                onPressed: () {
                  setState(() {
                    _step--;
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
                child: const Icon(Icons.arrow_back),
              ),
            ),
          const Spacer(),
          if (_step < 3)
            FloatingActionButton(
              heroTag: 'next',
              onPressed: () {
                setState(() {
                  _step++;
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              },
              child: const Icon(Icons.arrow_forward),
            )
          else
            FloatingActionButton.extended(
              onPressed: _isLoading ? null : _submitOrder,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Complete Order'),
            ),
        ],
      ),
    );
  }

  Widget buildFormStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Business Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          buildTextField('Business Name', Icons.business, namaUsahaController),
          buildTextField('Business Type', Icons.category, jenisUsahaController),
          buildTextField('Business Address', Icons.location_on, alamatUsahaController),
          buildTextField('Business Phone', Icons.phone, teleponUsahaController),
          buildTextField(
            'Business Description',
            Icons.description,
            deskripsiUsahaController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget buildFormStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Design Preferences',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          buildTextField('Design Theme', Icons.palette, temaController),
          buildTextField('Color Preferences', Icons.color_lens, warnaController),
          buildTextField('Size Requirements', Icons.straighten, ukuranController),
          buildTextField(
            'Text to Display',
            Icons.text_fields,
            kataKataController,
          ),
          buildTextField(
            'Additional Notes',
            Icons.note,
            catatanController,
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Reference Images',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          
          const SizedBox(height: 8),
          
          ElevatedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.file_upload),
            label: const Text('Upload Images'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          if (_selectedFiles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedFiles.length} files selected:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120, // Increased height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      final bool isImage = file.extension?.toLowerCase() != null && 
                          ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(file.extension?.toLowerCase());
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isImage && file.path != null && File(file.path!).existsSync())
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(file.path!),
                                        width: 90,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 90,
                                            height: 70,
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 90,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getFileIcon(file.extension),
                                        size: 40,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      file.name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedFiles.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildSummaryStep() {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Order Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Package information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.packageType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(widget.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.packageDescription),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Business Information
          Text(
            'Business Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          buildDetailRow('Business Name', namaUsahaController.text),
          buildDetailRow('Business Type', jenisUsahaController.text),
          buildDetailRow('Business Address', alamatUsahaController.text),
          buildDetailRow('Business Phone', teleponUsahaController.text),
          buildDetailRow('Business Description', deskripsiUsahaController.text),
          
          const SizedBox(height: 16),
          
          // Design Preferences
          Text(
            'Design Preferences',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          buildDetailRow('Theme', temaController.text),
          buildDetailRow('Colors', warnaController.text),
          buildDetailRow('Size', ukuranController.text),
          buildDetailRow('Text', kataKataController.text),
          buildDetailRow('Additional Notes', catatanController.text),
          
          const SizedBox(height: 8),
          buildDetailRow('Reference Images', '${_selectedFiles.length} files selected'),
        ],
      ),
    );
  }

  Widget buildPaymentStep() {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    // Updated payment method definitions with image paths
    final digitalPaymentMethods = [
      {'name': 'QRIS', 'image': 'assets/pembayaran/Qris.png'},
      {'name': 'GoPay', 'image': 'assets/pembayaran/Gopay.png'},
      {'name': 'DANA', 'image': 'assets/pembayaran/Dana.png'},
      {'name': 'ShopeePay', 'image': 'assets/pembayaran/Shopee.png'}
    ];
    
    final bankTransferMethods = [
      {'name': 'BCA', 'image': 'assets/pembayaran/BCA.png'},
      {'name': 'BRI', 'image': 'assets/pembayaran/BRI.png'},
      {'name': 'Mastercard', 'image': 'assets/pembayaran/Mastercard.png'},
      {'name': 'Visa', 'image': 'assets/pembayaran/Visa.png'}
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Payment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(widget.price),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Select Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 16),
          
          // Digital payment methods
          const Text(
            'Digital Payments',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: digitalPaymentMethods.map((method) {
              final isSelected = _selectedPaymentMethod == method['name'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method['name']!;
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Payment method icon
                      Image.asset(
                        method['image']!,
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      // Payment method name
                      Text(
                        method['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.blue, size: 16),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Bank transfer methods
          const Text(
            'Bank Transfer',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bankTransferMethods.map((method) {
              final isSelected = _selectedPaymentMethod == method['name'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method['name']!;
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Payment method icon
                      Image.asset(
                        method['image']!,
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      // Payment method name
                      Text(
                        method['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.blue, size: 16),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Payment details based on selected method
          if (_selectedPaymentMethod.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details - $_selectedPaymentMethod',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (['QRIS', 'GoPay', 'DANA', 'ShopeePay'].contains(_selectedPaymentMethod))
                    // Show QR code for digital payments
                    Column(
                      children: [
                        // Mock QR Code
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: CustomPaint(
                            painter: MockQRPainter(),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Scan with $_selectedPaymentMethod app',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Amount: ${formatter.format(widget.price)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        
                        // Extra space to prevent buttons from covering content
                        const SizedBox(height: 80),
                      ],
                    )
                  else
                    // Show bank account details for bank transfers
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_selectedPaymentMethod Bank Account',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        const Text('Account Number: 1234-5678-9012-3456'),
                        const Text('Account Name: KRESIGN DESIGN'),
                        
                        const SizedBox(height: 16),
                        
                        const Text('Please enter your bank account number for verification:'),
                        
                        const SizedBox(height: 8),
                        
                        TextField(
                          controller: noRekeningController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Your $_selectedPaymentMethod account number',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        
                        // Extra space to prevent buttons from covering content
                        const SizedBox(height: 80),
                      ],
                    ),
                ],
              ),
            ),
          // Add extra space at the bottom for floating action button
          if (_selectedPaymentMethod.isEmpty)
            const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine which icon to use for different file types
  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.insert_drive_file;
    
    extension = extension.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(extension)) {
      return Icons.image;
    } else if (['pdf'].contains(extension)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      return Icons.description;
    } else if (['xls', 'xlsx', 'csv'].contains(extension)) {
      return Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(extension)) {
      return Icons.slideshow;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return Icons.folder_zip;
    } else {
      return Icons.insert_drive_file;
    }
  }
}

// A painter to draw a mock QR code
class MockQRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 20;
    final random = math.Random(42); // Fixed seed for consistent look

    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        // Always draw the corners as fixed patterns
        if ((i < 7 && j < 7) || // Top-left corner
            (i < 7 && j > 12) || // Top-right corner
            (i > 12 && j < 7)) { // Bottom-left corner
          
          // Create the border pattern
          if (i == 0 || i == 6 || j == 0 || j == 6 ||
              (i >= 2 && i <= 4 && j >= 2 && j <= 4)) {
            canvas.drawRect(
              Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize),
              paint,
            );
          }
        } else if (random.nextBool()) { // Random fill for the rest
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