import 'package:flutter/material.dart';

class KetentuanPage extends StatelessWidget {
  const KetentuanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Ketentuan Penggunaan', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Syarat dan Ketentuan KRESIGN',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'Pendahuluan',
                  'Dengan mengakses dan menggunakan aplikasi KRESIGN, Anda menyetujui untuk terikat oleh ketentuan penggunaan ini. Jika Anda tidak menyetujui salah satu dari ketentuan ini, Anda tidak diperkenankan menggunakan atau mengakses layanan ini.'
                ),
                _buildSection(
                  'Layanan',
                  'KRESIGN menyediakan platform untuk menghubungkan desainer dengan klien yang membutuhkan jasa desain. Kami tidak bertanggung jawab atas kualitas hasil akhir desain dan interaksi antara desainer dan klien.'
                ),
                _buildSection(
                  'Penggunaan Akun',
                  'Anda bertanggung jawab untuk menjaga kerahasiaan akun dan kata sandi Anda. Aktivitas yang terjadi di akun Anda menjadi tanggung jawab Anda sepenuhnya. Anda harus segera memberi tahu kami jika ada penggunaan tidak sah pada akun Anda.'
                ),
                _buildSection(
                  'Pembayaran dan Biaya',
                  'Biaya layanan akan dirinci sebelum Anda memesan jasa. Semua pembayaran bersifat final dan tidak dapat dikembalikan kecuali dinyatakan lain dalam kebijakan pengembalian dana kami. Kami berhak mengubah biaya layanan kapan saja.'
                ),
                _buildSection(
                  'Hak Kekayaan Intelektual',
                  'Setelah pembayaran penuh dilakukan, klien memiliki hak atas hasil desain. Namun, KRESIGN dan desainer berhak menampilkan karya tersebut di portofolio kecuali disepakati lain secara tertulis.'
                ),
                _buildSection(
                  'Batasan Tanggung Jawab',
                  'KRESIGN tidak bertanggung jawab atas kerugian langsung, tidak langsung, atau konsekuensial yang timbul dari penggunaan atau ketidakmampuan menggunakan layanan.'
                ),
                _buildSection(
                  'Perubahan Ketentuan',
                  'Kami berhak mengubah ketentuan penggunaan ini kapan saja. Perubahan akan berlaku segera setelah diposting di aplikasi. Penggunaan berkelanjutan dari layanan kami setelah perubahan merupakan penerimaan Anda terhadap ketentuan yang diperbarui.'
                ),
                _buildSection(
                  'Hukum yang Berlaku',
                  'Ketentuan ini diatur oleh dan ditafsirkan sesuai dengan hukum Indonesia, tanpa memperhatikan prinsip-prinsip konflik hukum.'
                ),
                _buildSection(
                  'Kontak',
                  'Jika Anda memiliki pertanyaan tentang ketentuan penggunaan ini, silakan hubungi kami di support@kresign.id'
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Saya Mengerti'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}