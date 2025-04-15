import 'package:flutter/material.dart';
import 'test_login_page.dart';

class SignUpChoicePage extends StatelessWidget {
  const SignUpChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Akun Kreatif Design',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Daftar Sebagai',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChoiceBox(
                  icon: Icons.shopping_bag,
                  label: 'Client',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignUpClientPage(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                _buildChoiceBox(
                  icon: Icons.palette,
                  label: 'Designer',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignUpDesignerPage(),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceBox({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 60),
            const SizedBox(height: 10),
            Text(label)
          ],
        ),
      ),
    );
  }
}

class SignUpClientPage extends StatelessWidget {
  const SignUpClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SignUpForm(
      title: 'Daftar Akun Client',
      fields: const [
        _FormFieldData(icon: Icons.person, hint: 'Nama Lengkap'),
        _FormFieldData(icon: Icons.email, hint: 'Email Pengguna'),
        _FormFieldData(icon: Icons.lock, hint: 'Kata Sandi'),
        _FormFieldData(icon: Icons.phone, hint: 'No. Telepon'),
      ],
    );
  }
}

class SignUpDesignerPage extends StatelessWidget {
  const SignUpDesignerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SignUpForm(
      title: 'Daftar Akun Desainer',
      fields: const [
        _FormFieldData(icon: Icons.person, hint: 'Nama Lengkap'),
        _FormFieldData(icon: Icons.email, hint: 'Email Pengguna'),
        _FormFieldData(icon: Icons.lock, hint: 'Kata Sandi'),
        _FormFieldData(icon: Icons.phone, hint: 'No. Telepon'),
        _FormFieldData(icon: Icons.credit_card, hint: 'NIK'),
        _FormFieldData(icon: Icons.badge, hint: 'KTP'),
        _FormFieldData(icon: Icons.location_on, hint: 'Alamat', maxLines: 3),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  final String title;
  final List<_FormFieldData> fields;

  const _SignUpForm({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.grey)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Daftar Akun',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black12,
              child: Icon(Icons.add_photo_alternate, size: 40),
            ),
            const SizedBox(height: 16),
            ...fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                maxLines: f.maxLines,
                decoration: InputDecoration(
                  hintText: f.hint,
                  prefixIcon: Icon(f.icon),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                ),
              ),
            )),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Daftar'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
               children: [
                const Text('Sudah punya akun?'),
                TextButton(
                  // Replace the Navigator.pop with navigation to LoginPage
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Login!', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Sign Up dengan Sosial Media'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.facebook, size: 32),
                SizedBox(width: 16),
                Icon(Icons.g_mobiledata, size: 32),
                SizedBox(width: 16),
                Icon(Icons.close, size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormFieldData {
  final IconData icon;
  final String hint;
  final int maxLines;

  const _FormFieldData({
    required this.icon,
    required this.hint,
    this.maxLines = 1,
  });
}