import 'package:flutter/material.dart';

class BrainstormingTipsPage extends StatelessWidget {
  const BrainstormingTipsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brainstorming dalam 5 Menit'),
        backgroundColor: const Color(0xFF2D3B47),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/tips/brainstroming5menit.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tips Brainstorming Ide dalam 5 Menit',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3B47),
              ),
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              '1. Gunakan Timer',
              'Atur waktu hanya 5 menit untuk mendorong otak bekerja lebih cepat dan fokus.'
            ),
            _buildTipItem(
              '2. Jangan Menilai Ide',
              'Tulis semua ide yang muncul tanpa menilai atau mengkritik. Kuantitas lebih penting daripada kualitas di tahap ini.'
            ),
            _buildTipItem(
              '3. Gunakan Mind Mapping',
              'Tulis ide utama di tengah kertas, lalu buat cabang untuk setiap ide turunan yang muncul.'
            ),
            _buildTipItem(
              '4. Cari Inspirasi Visual',
              'Siapkan beberapa referensi visual sebelumnya yang bisa dilihat sekilas untuk memicu ide-ide baru.'
            ),
            _buildTipItem(
              '5. Ubah Perspektif',
              'Coba lihat masalah dari sudut pandang yang berbeda, seperti dari mata pengguna atau kompetitor.'
            ),
            _buildTipItem(
              '6. Gabungkan Ide yang Tidak Berhubungan',
              'Ambil dua konsep yang tidak berhubungan dan coba gabungkan untuk menciptakan sesuatu yang baru.'
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Penting:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Brainstorming cepat terasa lebih efektif setelah dilakukan berulang kali. Jadikan ini sebagai kebiasaan dan Anda akan melatih otak untuk berpikir kreatif dengan lebih cepat.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3B47),
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