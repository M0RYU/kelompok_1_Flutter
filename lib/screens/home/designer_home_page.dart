import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../order/order_history_page.dart';
import '../chat/chat_list_page.dart';
import '../profile/profile_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../tips/brainstorming_tips_page.dart';
import '../tips/simple_elegant_design_page.dart';
import '../about/developer_page.dart';
import '../about/about_kresign_page.dart';

class DesignerHomePage extends StatefulWidget {
  const DesignerHomePage({Key? key}) : super(key: key);

  @override
  State<DesignerHomePage> createState() => _DesignerHomePageState();
}

class _DesignerHomePageState extends State<DesignerHomePage> {
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
                      Text(_userName ?? 'Designer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 6),
                      const Text('Anda memiliki', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  GestureDetector(
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusBox('2', 'Order baru'),
                _buildStatusBox('1', 'Dalam Pengerjaan'),
                _buildStatusBox('2', 'Dalam Review'),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Text('TIPS DESIGN KREATIF UNTUK KAMU!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildTipsSlider(['5 MENIT!', 'SIMPLE But ELEGANT', 'INSPIRASI BARU', 'TIPS PRO']),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Text('Tentang KRESIGN!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildGridContent(['Apa sih KRESIGN?', 'KRESIGN App!']),
            const SizedBox(height: 20),
          ],
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
  
  Widget _buildTipsSlider(List<String> titles) {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return _buildTipCard(titles[index], index);
        },
      ),
    );
  }
  
  Widget _buildTipCard(String title, int index) {
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
        width: 180,
        height: 130,
        margin: const EdgeInsets.only(right: 16),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: imagePath.isNotEmpty 
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                )
              : Text(
                  title, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBox(String number, String label) {
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3B47),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(number, style: const TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGridContent(List<String> titles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: titles.map((title) => _buildCard(title)).toList(),
      ),
    );
  }

  Widget _buildCard(String title) {
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
        width: 150,
        height: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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