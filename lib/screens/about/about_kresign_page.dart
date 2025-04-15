import 'package:flutter/material.dart';

class AboutKresignPage extends StatelessWidget {
  const AboutKresignPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apa itu KRESIGN?'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo atau gambar Kresign
            Center(
              child: Image.asset(
                'assets/home/Apaitukresign.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tentang KRESIGN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'KRESIGN adalah platform yang menghubungkan desainer kreatif dengan klien yang membutuhkan jasa desain. Kami didirikan dengan tujuan memfasilitasi kolaborasi yang lancar dan efisien dalam industri desain grafis.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tujuan KRESIGN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTujuanItem(
              '1. Menghubungkan Klien dengan Desainer',
              'KRESIGN bertujuan untuk menjembatani kesenjangan antara klien yang membutuhkan desain berkualitas dan desainer berbakat yang menawarkan layanan mereka. Platform ini memudahkan klien menemukan desainer yang tepat untuk proyek mereka.'
            ),
            _buildTujuanItem(
              '2. Menyederhanakan Proses Desain',
              'Kami membuat proses pemesanan, pembayaran, dan pengiriman hasil desain menjadi lebih terstruktur dan transparan. Dengan alur kerja yang jelas, baik klien maupun desainer dapat fokus pada yang penting: menciptakan desain yang luar biasa.'
            ),
            _buildTujuanItem(
              '3. Mendukung Industri Kreatif Lokal',
              'KRESIGN berkomitmen untuk mendukung pertumbuhan industri kreatif Indonesia dengan menyediakan platform yang memungkinkan desainer lokal untuk menampilkan karya mereka dan mendapatkan proyek dari berbagai klien.'
            ),
            _buildTujuanItem(
              '4. Memberikan Kemudahan Akses',
              'Dengan aplikasi yang user-friendly, KRESIGN memastikan bahwa siapa pun dapat mengakses layanan desain berkualitas tanpa kerumitan, baik untuk kebutuhan bisnis maupun personal.'
            ),
            _buildTujuanItem(
              '5. Menjamin Kualitas Desain',
              'Platform ini dirancang untuk memastikan klien mendapatkan hasil desain yang sesuai dengan kebutuhan mereka dan memenuhi standar kualitas tertinggi dalam industri desain grafis.'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTujuanItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}