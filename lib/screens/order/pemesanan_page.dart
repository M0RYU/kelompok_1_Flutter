import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import 'order_stepper.dart';

class PackageLandingPage extends StatefulWidget {
  const PackageLandingPage({Key? key}) : super(key: key);

  @override
  State<PackageLandingPage> createState() => _PackageLandingPageState();
}

class _PackageLandingPageState extends State<PackageLandingPage> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  void _navigateToOrderStepper() {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderStepperPage(
          packageType: 'Logo Design',
          price: 350000,
          packageDescription: 'Get a professionally designed logo for your business or brand. Our designers will create a unique and memorable logo that represents your identity.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Package Details', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package Header Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage('assets/Logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package Title
                  const Text(
                    'Logo Design Package',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Package Price
                  const Text(
                    'Rp 350,000',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Package Description
                  const Text(
                    'Package description:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get a professionally designed logo for your business or brand. Our designers will create a unique and memorable logo that represents your identity.',
                    style: TextStyle(fontSize: 14),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // What's included
                  const Text(
                    "What's included:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildIncludedItem('3 initial concepts'),
                  _buildIncludedItem('2 rounds of revisions'),
                  _buildIncludedItem('Final files in multiple formats (PNG, JPG, SVG)'),
                  _buildIncludedItem('Full copyright ownership'),
                  
                  const SizedBox(height: 16),
                  
                  // Delivery Time
                  _buildDetailsItem('Delivery Time', '3-5 working days'),
                  
                  // Revisions
                  _buildDetailsItem('Revisions', '2 rounds included'),
                  
                  // Format
                  _buildDetailsItem('Final Format', 'PNG, JPG, SVG, PDF'),
                  
                  const SizedBox(height: 24),
                  
                  // Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _navigateToOrderStepper,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Order Now',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIncludedItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailsItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}