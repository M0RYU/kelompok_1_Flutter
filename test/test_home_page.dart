import 'package:flutter/material.dart';
import  'test_Ketentuan_page.dart';

class HomePageDesigner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat datang kembali di KRESIGN', style: TextStyle(fontSize: 14)),
                      SizedBox(height: 6),
                      Text('Anhar Putranto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 6),
                      Text('Anda memiliki', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusBox('2', 'Order baru'),
                _buildStatusBox('1', 'Dalam Pengerjaan'),
                _buildStatusBox('2', 'Dalam Review'),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Text('TIPS DESIGN KREATIF UNTUK KAMU!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildTipsSlider(['5 MENIT!', 'SIMPLE But ELEGANT', 'INSPIRASI BARU', 'TIPS PRO']),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Text('Tentang KRESIGN!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildGridContent(['Apa sih KRESIGN?', 'KRESIGN App!'], 2),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: 0, 
        onTap: (index) {
          if (index != 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  if (index == 1) return OrderHistoryPage();
                  if (index == 2) return ChatListPage();
                  return ProfilePage();
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
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return _buildTipCard(titles[index]);
        },
      ),
    );
  }
  
  Widget _buildTipCard(String title) {
    return Container(
      width: 180,
      height: 130,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            title, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF2D3B47),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 3,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(number, style: TextStyle(color: Colors.white, fontSize: 22)),
          SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGridContent(List<String> titles, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: titles.map((title) => _buildCard(title)).toList(),
      ),
    );
  }

  Widget _buildCard(String title) {
    return Container(
      width: 150,
      height: 100,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            title, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat datang kembali di KRESIGN', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 6),
                        Text('Fufufafa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        SizedBox(height: 6),
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
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(Icons.person, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Text('Paket Design', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildDesignPackages([
                'Paket Design Kemasan Box',
                'Paket Design Logo',
                'Paket Design Sticker Kemasan'
              ], context),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Text('Tentang KRESIGN!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildGridContent(['Apa sih KRESIGN?', 'KRESIGN App!'], 2),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  if (index == 1) return OrderHistoryPage();
                  if (index == 2) return ChatListPage();
                  return ProfilePage();
                },
              ),
            );
          }
        }
      ),
    );
  }

  Widget _buildDesignPackages(List<String> titles, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = 20.0;
    double spaceBetween = 8.0;
    double availableWidth = screenWidth - (2 * horizontalPadding);
    double cardWidth = (availableWidth - (2 * spaceBetween)) / 3;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: titles.map((title) => 
          _buildPackageCard(context, title, cardWidth)
        ).toList(),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, String title, double width) {
    return Container(
      width: width,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            title, 
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridContent(List<String> titles, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: titles.map((title) => _buildCard(title)).toList(),
      ),
    );
  }

  Widget _buildCard(String title) {
    return Builder(
      builder: (BuildContext context) => Container(
        width: MediaQuery.of(context).size.width * 0.42,
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 3,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            title, 
            textAlign: TextAlign.center,
            style: TextStyle(
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

// 6. Order History Page
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePageDesigner()));
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (index == 2) return ChatListPage();
                    return ProfilePage();
                  },
                ),
              );
            }
          }
        }
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Riwayat Pemesanan', style: TextStyle(color: Colors.black)),
        actions: [
          DropdownButton<String>(
            value: 'Semua',
            items: const [
              DropdownMenuItem(value: 'Semua', child: Text('Semua')),
              DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
            ],
            onChanged: (value) {},
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('POSK'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('1234-NATR676765'),
                  Text('2025-04-08 08:20'),
                  Text('fufufafa@gmail.com')
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 7. Chat List Page
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePageDesigner()));
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (index == 1) return OrderHistoryPage();
                    return ProfilePage();
                  },
                ),
              );
            }
          }
        }
      ),
      appBar: AppBar(
        title: const Text('Chat', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[300],
      ),
      body: ListView(
        children: const [
          _ChatTile(name: 'Althena', message: 'Desain yang bagus! Saya beri bintang 5!'),
          _ChatTile(name: 'Akille', message: 'Wah hasilnya bagus, makasih banyak yahh...'),
          _ChatTile(name: 'Phontoon', message: 'Pengiriman untuk versi yang bisa di-edit ya yang berikut.'),
          _ChatTile(name: 'Henry', message: 'Produk saya sekarang jadi lebih dilirik!'),
          _ChatTile(name: 'Josala', message: 'Pelayanan yang baik.'),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String message;
  const _ChatTile({required this.name, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(message),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatDetailPage()),
      ),
    );
  }
}

// 8. Chat Detail Page
class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Raphiel', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Revvy99991', style: TextStyle(backgroundColor: Colors.white)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Desainnya sudah jadi', style: TextStyle(color: Colors.white, backgroundColor: Colors.black)),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ketik Pesanmu disini...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 9. Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            if (index == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePageDesigner()));
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (index == 1) return OrderHistoryPage();
                    return ChatListPage();
                  },
                ),
              );
            }
          }
        }
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header with photo on left, name and email on right
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 50, 
                      child: Icon(Icons.person, size: 50)
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Anhar Putranto', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                          ),
                          SizedBox(height: 5),
                          Text(
                            'anhar.putranto.vix23@edu.pnj.ac.id',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                
                // Buttons with increased size
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.black, width: 0.3),
                    ),
                    ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                  }, 
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 16))
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.black, width: 0.3),
                    ),
                  ),
                    onPressed: () {}, 
                    child: const Text('Bantuan', style: TextStyle(fontSize: 16))
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.black, width: 0.3),
                    ),
                  ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const KetentuanPage()));
                    }, 
                    child: const Text('Ketentuan', style: TextStyle(fontSize: 16))
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 10. Edit Profile Page
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Foto Profile'), backgroundColor: Colors.grey[300]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 10),
            const Icon(Icons.add),
            const TextField(decoration: InputDecoration(hintText: 'Nama')),
            const TextField(decoration: InputDecoration(hintText: 'E-mail')),
            const TextField(decoration: InputDecoration(hintText: 'Nomor Telepon')),
            const TextField(decoration: InputDecoration(hintText: 'Alamat')),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Simpan'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Bottom Navigation Bar - updated to handle navigation
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  
  const _BottomNavBar({required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}
