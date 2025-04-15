import 'package:flutter/material.dart';

class KetentuanPage extends StatelessWidget {
  const KetentuanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Terms and Conditions', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        const Text(
          'Ketentuan Penggunaan KRESIGN',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Terakhir Diperbarui: 9 April 2024',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          'PERSETUJUAN KETENTUAN',
          'Ketentuan Penggunaan ini merupakan perjanjian yang mengikat secara hukum antara Anda dan KRESIGN terkait akses dan penggunaan aplikasi serta situs web KRESIGN. Dengan membuat akun atau menggunakan layanan kami, Anda menyetujui Ketentuan Penggunaan ini.',
        ),
        _buildSection(
          'PENDAFTARAN PENGGUNA',
          'Anda mungkin diminta untuk mendaftar di aplikasi untuk mengakses layanan kami. Anda setuju untuk menjaga kerahasiaan kata sandi Anda dan bertanggung jawab atas semua aktivitas yang dilakukan melalui akun Anda. Kami berhak untuk menghapus atau mengklaim kembali nama pengguna.',
        ),
        _buildSection(
          'LAYANAN',
          'KRESIGN menyediakan platform yang menghubungkan desainer dan klien untuk layanan desain grafis. Kami tidak menjamin kualitas, keamanan, akurasi, atau legalitas layanan yang diberikan oleh desainer. Semua transaksi antara desainer dan klien adalah tanggung jawab mereka masing-masing.',
        ),
        _buildSection(
          'TANGGUNG JAWAB PENGGUNA',
          '• Memberikan informasi yang akurat saat membuat akun.\n'
          '• Menjaga kerahasiaan akun Anda.\n'
          '• Tidak menggunakan layanan untuk tujuan ilegal.\n'
          '• Mematuhi semua hukum dan peraturan yang berlaku.\n'
          '• Tidak mendistribusikan malware atau kode berbahaya.',
        ),
        _buildSection(
          'TANGGUNG JAWAB DESAINER',
          '• Menyelesaikan proyek sesuai dengan persyaratan dan tenggat waktu yang disepakati.\n'
          '• Menjaga komunikasi profesional dengan klien.\n'
          '• Menghasilkan konten orisinal yang tidak melanggar hak kekayaan intelektual.',
        ),
        _buildSection(
          'TANGGUNG JAWAB KLIEN',
          '• Memberikan arahan dan persyaratan yang jelas untuk proyek.\n'
          '• Membayar layanan yang telah selesai sesuai dengan persyaratan yang disepakati.\n'
          '• Berkomunikasi dengan desainer secara sopan.',
        ),
        _buildSection(
          'PEMBAYARAN',
          'Klien setuju untuk membayar layanan desain melalui platform kami. Semua pembayaran diproses dengan aman melalui penyedia pembayaran pihak ketiga. Desainer akan menerima pembayaran setelah klien menyetujui hasil akhir.',
        ),
        _buildSection(
          'KEBIJAKAN PENGEMBALIAN DANA',
          'Pengembalian dana dapat diberikan atas kebijakan kami, biasanya dalam kasus di mana desainer gagal memberikan layanan yang disepakati atau jika hasil kerja yang diberikan sangat menyimpang dari persyaratan yang disepakati.',
        ),
        _buildSection(
          'HAK KEKAYAAN INTELEKTUAL',
          'Setelah proyek selesai dan pembayaran penuh dilakukan, klien menerima semua hak kekayaan intelektual atas desain yang diberikan. Desainer berhak untuk memamerkan karya tersebut dalam portofolio mereka kecuali ditentukan lain.',
        ),
        _buildSection(
          'BATASAN TANGGUNG JAWAB',
          'KRESIGN tidak bertanggung jawab atas kerugian tidak langsung, insidental, khusus, konsekuensial, atau hukuman yang timbul dari penggunaan atau ketidakmampuan Anda untuk menggunakan layanan.',
        ),
        _buildSection(
          'PENGHENTIAN',
          'Kami dapat menghentikan atau menangguhkan akun Anda segera, tanpa pemberitahuan sebelumnya, karena alasan apa pun, termasuk tetapi tidak terbatas pada pelanggaran Ketentuan Penggunaan ini.',
        ),
        _buildSection(
          'PERUBAHAN KETENTUAN',
          'Kami berhak untuk mengubah ketentuan ini kapan saja. Kami akan memberikan pemberitahuan tentang perubahan signifikan dengan memposting Ketentuan Penggunaan yang baru di halaman ini.',
        ),
        _buildSection(
          'HUBUNGI KAMI',
          'Jika Anda memiliki pertanyaan tentang Ketentuan Penggunaan ini, silakan hubungi kami di:\n\nsupport@kresign.example.com',
        ),
        const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }
}