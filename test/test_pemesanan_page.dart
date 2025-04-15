import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Icon(Icons.keyboard_backspace, size: 30),
              ),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 200,
                height: 150,
                color: Colors.grey[100],
                child: Image.network('https://via.placeholder.com/150', fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Paket Design kemasan Box',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Paket Desain Kemasan Box hanya mencakup pembuatan desain untuk kemasan box tanpa menyertakan pembuatan atau desain ulang logo usaha. Jika Anda sudah memiliki logo, silakan unggah file logo usaha Anda agar dapat kami integrasikan ke dalam desain kemasan.',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1C3C3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderStepper()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Order Sekarang!'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OrderStepper extends StatefulWidget {
  @override
  State<OrderStepper> createState() => _OrderStepperState();
}

class _OrderStepperState extends State<OrderStepper> {
  int _step = 0;
  final _pageController = PageController();

  // Controllers for form inputs
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_backspace),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Paket Design kemasan Box',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _step >= index ? Colors.black : Colors.grey,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (index < 3)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: _step > index ? Colors.black : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
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
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 30),
          if (_step > 0)
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                setState(() {
                  _step--;
                  _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                });
              },
            ),
          Spacer(),
          if (_step < 3)
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                setState(() {
                  _step++;
                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                });
              },
            ),
          SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget buildFormStep1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Informasi Usaha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          SizedBox(height: 16),
          buildTextField('Nama Usaha', Icons.apartment, namaUsahaController),
          buildTextField('Jenis Usaha', Icons.article, jenisUsahaController),
          buildTextField('Alamat Usaha', Icons.location_pin, alamatUsahaController),
          buildTextField('Nomor Telepon Usaha', Icons.phone, teleponUsahaController),
          buildTextField('Deskripsi Usaha', Icons.description, deskripsiUsahaController),
        ],
      ),
    );
  }

  Widget buildFormStep2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Preferensi Design', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          SizedBox(height: 16),
          buildTextField('Tema Design', Icons.format_paint, temaController),
          buildTextField('Warna Design', Icons.palette, warnaController),
          buildTextField('Ukuran Design', Icons.straighten, ukuranController),
          buildTextField('kata-Kata untuk ditampilkan', Icons.text_fields, kataKataController),
          buildTextField('Catatan pesanan', Icons.note, catatanController),
        ],
      ),
    );
  }

  Widget buildSummaryStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                buildDetailRow('Nama Usaha', namaUsahaController.text),
                buildDetailRow('Jenis Usaha', jenisUsahaController.text),
                buildDetailRow('Alamat', alamatUsahaController.text),
                buildDetailRow('Telepon', teleponUsahaController.text),
                buildDetailRow('Deskripsi', deskripsiUsahaController.text),
                buildDetailRow('Tema', temaController.text),
                buildDetailRow('Warna', warnaController.text),
                buildDetailRow('Ukuran', ukuranController.text),
                buildDetailRow('Kata-Kata', kataKataController.text),
                buildDetailRow('Catatan', catatanController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentStep() {
    List<String> logos = [
      'QRIS', 'BCA', 'BRI', 'gopay', 'DANA', 'Shopee Pay', 'Alfamart', 'MasterCard', 'VISA'
    ];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3,
        children: logos.map((e) => Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[300],
          ),
          child: Center(child: Text(e)),
        )).toList(),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
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
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value.isNotEmpty ? value : '-')),
        ],
      ),
    );
  }
}