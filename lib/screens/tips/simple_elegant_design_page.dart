import 'package:flutter/material.dart';

class SimpleElegantDesignPage extends StatelessWidget {
  const SimpleElegantDesignPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Simple tapi Elegan'),
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
                  'assets/tips/simpleelegant.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cara Mendesain yang Simple tapi Elegan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3B47),
              ),
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              '1. Gunakan Whitespace dengan Bijak',
              'Ruang kosong adalah elemen desain yang kuat. Berikan objek-objek dalam desain Anda ruang untuk "bernapas" sehingga tampak lebih rapi dan mudah dibaca.'
            ),
            _buildTipItem(
              '2. Pilih Palet Warna Minimalis',
              'Pilih 2-3 warna utama dan gunakan dengan konsisten. Warna monokromatik atau warna-warna netral dengan satu aksen warna cerah dapat menciptakan tampilan yang elegan.'
            ),
            _buildTipItem(
              '3. Kurangi Detail yang Tidak Perlu',
              'Hilangkan elemen-elemen yang tidak menambah nilai pada desain Anda. Setiap komponen harus memiliki tujuan yang jelas.'
            ),
            _buildTipItem(
              '4. Pilih Tipografi yang Tepat',
              'Gunakan maksimal 2 jenis font yang kontras namun harmonis, seperti sans-serif untuk judul dan serif untuk badan teks. Konsistensi adalah kunci.'
            ),
            _buildTipItem(
              '5. Perhatikan Hierarki Visual',
              'Buatlah perbedaan yang jelas antara elemen utama dan sekunder menggunakan ukuran, warna, atau bobot font yang berbeda.'
            ),
            _buildTipItem(
              '6. Gunakan Garis dan Bentuk Sederhana',
              'Bentuk geometris dan garis lurus menciptakan kesan rapi dan terorganisir. Terlalu banyak kurva dan bentuk kompleks dapat membuat desain terlihat berantakan.'
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingat:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"Simplicity is the ultimate sophistication" - Leonardo da Vinci. Desain yang baik bukan ketika tidak ada lagi yang bisa ditambahkan, melainkan ketika tidak ada lagi yang bisa dihilangkan.',
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