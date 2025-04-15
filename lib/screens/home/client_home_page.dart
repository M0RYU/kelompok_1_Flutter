import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../order/pemesanan_page.dart';
import '../order/order_history_page.dart';
import '../order/order_stepper.dart'; // Added this import for OrderStepperPage
import '../chat/chat_list_page.dart';
import '../profile/profile_page.dart';
import '../about/developer_page.dart'; // Import halaman pengembang
import '../about/about_kresign_page.dart'; // Import halaman tentang Kresign
import '../tips/brainstorming_tips_page.dart';
import '../tips/simple_elegant_design_page.dart';
import '../../widgets/bottom_nav_bar.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  String? _userName;
  String? _photoURL;

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
        _userName = userData.name;
        _photoURL = userData.photoURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat datang kembali di KRESIGN', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 6),
                        Text(_userName ?? 'Client', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 6),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 3,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfilePage()),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          backgroundImage: _photoURL != null ? NetworkImage(_photoURL!) : null,
                          child: _photoURL == null ? const Icon(Icons.person, size: 40) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Text('Paket Design', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildDesignPackages([
                'Paket Design Kemasan Box',
                'Paket Design Logo',
                'Paket Design Sticker Kemasan'
              ]),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Text('Tips untuk Designer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildDesignTips([
                'Brainstorming Ide dalam 5 Menit',
                'Design Simple tapi Elegan',
                'Memilih Color Palette yang Tepat',
                'Typography yang Efektif'
              ]),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Text('Tentang KRESIGN!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildGridContent(['Apa sih KRESIGN?', 'KRESIGN App!']),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  if (index == 1) return const OrderHistoryPage();
                  if (index == 2) return const ChatListPage();
                  return const ProfilePage();
                },
              ),
            );
          }
        }
      ),
    );
  }

  Widget _buildDesignPackages(List<String> titles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: titles.map((title) => 
          _buildPackageCard(title)
        ).toList(),
      ),
    );
  }

  Widget _buildPackageCard(String title) {
    String packageType = title;
    double price = 0;
    String description = '';
    String imagePath = ''; // Added image path variable
    
    // Set price, description and image path based on package type
    if (title.contains('Kemasan Box')) {
      price = 400000;
      description = 'Professional box packaging design for your products. Includes multiple views and print-ready files.';
      imagePath = 'assets/PaketDesign/paketbox.png'; // Box package image
    } else if (title.contains('Logo')) {
      price = 350000;
      description = 'Get a professionally designed logo for your business or brand. Our designers will create a unique and memorable logo that represents your identity.';
      imagePath = 'assets/PaketDesign/paketlogo.png'; // Logo package image
    } else if (title.contains('Sticker')) {
      price = 250000;
      description = 'Custom sticker design for product packaging, branding, or promotional materials. Includes print-ready files in various formats.';
      imagePath = 'assets/PaketDesign/paketstiker.png'; // Sticker package image
    }
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderStepperPage(
            packageType: packageType,
            price: price,
            packageDescription: description,
          ),
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title.replaceAll('Paket Design ', ''),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignTips(List<String> tips) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: tips.asMap().entries.map((entry) {
          int index = entry.key;
          String tip = entry.value;
          return _buildTipCard(tip, index);
        }).toList(),
      ),
    );
  }

  Widget _buildTipCard(String tip, int index) {
    String imagePath = '';
    Widget Function(BuildContext) navigationPage = (_) => const Scaffold();
    
    // Assign images and navigation targets for the first two cards
    if (index == 0) {
      imagePath = 'assets/tips/brainstroming5menit.png';
      navigationPage = (_) => const BrainstormingTipsPage();
    } else if (index == 1) {
      imagePath = 'assets/tips/simpleelegant.png';
      navigationPage = (_) => const SimpleElegantDesignPage();
    }
    
    return GestureDetector(
      onTap: imagePath.isNotEmpty ? () => Navigator.push(
        context,
        MaterialPageRoute(builder: navigationPage),
      ) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            if (imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContent(List<String> titles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: titles.map((title) => _buildInfoCard(title)).toList(),
      ),
    );
  }

  Widget _buildInfoCard(String title) {
    // Tentukan gambar yang akan digunakan berdasarkan judul
    String imagePath;
    if (title == 'Apa sih KRESIGN?') {
      imagePath = 'assets/home/Apaitukresign.png';
    } else if (title == 'KRESIGN App!') {
      imagePath = 'assets/home/kresignapp.png';
    } else {
      imagePath = ''; // Default fallback path jika perlu
    }

    return GestureDetector(
      onTap: () {
        // Mengubah navigasi: KRESIGN App! mengarah ke halaman pengembang
        // Apa sih KRESIGN? mengarah ke halaman informasi Kresign
        if (title == 'KRESIGN App!') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DeveloperPage()),
          );
        } else if (title == 'Apa sih KRESIGN?') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutKresignPage()),
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: imagePath.isNotEmpty 
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                )
              : Text(
                  title, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}