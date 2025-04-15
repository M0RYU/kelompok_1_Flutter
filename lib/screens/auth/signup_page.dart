import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_page.dart';
import '../../services/auth_service.dart';

class SignUpChoicePage extends StatelessWidget {
  const SignUpChoicePage({Key? key}) : super(key: key);

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

  Widget _buildChoiceBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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

class SignUpClientPage extends StatefulWidget {
  const SignUpClientPage({Key? key}) : super(key: key);

  @override
  State<SignUpClientPage> createState() => _SignUpClientPageState();
}

class _SignUpClientPageState extends State<SignUpClientPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  File? _profileImage;
  bool _isLoading = false;
  String? _errorMessage;
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }
  
  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: 'client',
      );
      
      if (!mounted) return;
      
      // Show success and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SignUpForm(
      title: 'Daftar Akun Client',
      onPickImage: _pickImage,
      profileImage: _profileImage,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onSubmit: _handleSignUp,
      fields: [
        _FormFieldData(
          controller: _nameController,
          icon: Icons.person,
          hint: 'Nama Lengkap',
        ),
        _FormFieldData(
          controller: _emailController,
          icon: Icons.email,
          hint: 'Email Pengguna',
          keyboardType: TextInputType.emailAddress,
        ),
        _FormFieldData(
          controller: _passwordController,
          icon: Icons.lock,
          hint: 'Kata Sandi',
          isPassword: true,
        ),
        _FormFieldData(
          controller: _phoneController,
          icon: Icons.phone,
          hint: 'No. Telepon',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class SignUpDesignerPage extends StatefulWidget {
  const SignUpDesignerPage({Key? key}) : super(key: key);

  @override
  State<SignUpDesignerPage> createState() => _SignUpDesignerPageState();
}

class _SignUpDesignerPageState extends State<SignUpDesignerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _ktpController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  File? _profileImage;
  bool _isLoading = false;
  String? _errorMessage;
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }
  
  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: 'designer',
        nik: _nikController.text.trim(),
      );
      
      if (!mounted) return;
      
      // Show success and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nikController.dispose();
    _ktpController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SignUpForm(
      title: 'Daftar Akun Desainer',
      onPickImage: _pickImage,
      profileImage: _profileImage,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onSubmit: _handleSignUp,
      fields: [
        _FormFieldData(
          controller: _nameController,
          icon: Icons.person,
          hint: 'Nama Lengkap',
        ),
        _FormFieldData(
          controller: _emailController,
          icon: Icons.email,
          hint: 'Email Pengguna',
          keyboardType: TextInputType.emailAddress,
        ),
        _FormFieldData(
          controller: _passwordController,
          icon: Icons.lock,
          hint: 'Kata Sandi',
          isPassword: true,
        ),
        _FormFieldData(
          controller: _phoneController,
          icon: Icons.phone,
          hint: 'No. Telepon',
          keyboardType: TextInputType.phone,
        ),
        _FormFieldData(
          controller: _nikController,
          icon: Icons.credit_card,
          hint: 'NIK',
        ),
        _FormFieldData(
          controller: _ktpController,
          icon: Icons.badge,
          hint: 'KTP',
        ),
        _FormFieldData(
          controller: _addressController,
          icon: Icons.location_on,
          hint: 'Alamat',
          maxLines: 3,
        ),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  final String title;
  final List<_FormFieldData> fields;
  final File? profileImage;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? errorMessage;

  const _SignUpForm({
    required this.title,
    required this.fields,
    required this.onPickImage,
    required this.onSubmit,
    this.profileImage,
    this.isLoading = false,
    this.errorMessage,
  });

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
            GestureDetector(
              onTap: onPickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black12,
                backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.add_photo_alternate, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            ...fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: f.controller,
                    obscureText: f.isPassword,
                    keyboardType: f.keyboardType,
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
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
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
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child:
                      const Text('Login!', style: TextStyle(color: Colors.blue)),
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
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final int maxLines;
  final bool isPassword;
  final TextInputType keyboardType;

  const _FormFieldData({
    required this.controller,
    required this.icon,
    required this.hint,
    this.maxLines = 1,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });
}