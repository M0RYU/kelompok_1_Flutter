import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../home/client_home_page.dart';
import '../home/designer_home_page.dart';
import '../order/order_history_page.dart';
import '../chat/chat_list_page.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';
import 'ketentuan_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  UserModel? _user;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = await authService.getCurrentUserData();
      
      if (!mounted) return;
      
      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Please sign in to view your profile'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Profile Image
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _user?.photoURL != null
                                  ? NetworkImage(_user!.photoURL!)
                                  : null,
                              child: _user?.photoURL == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            
                            // User Name
                            Text(
                              _user?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            // User Type Badge
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _user?.userType == 'designer'
                                    ? Colors.blue[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _user?.userType == 'designer' ? 'Designer' : 'Client',
                                style: TextStyle(
                                  color: _user?.userType == 'designer'
                                      ? Colors.blue[800]
                                      : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Edit Profile Button
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfilePage(user: _user!),
                                  ),
                                ).then((_) => _loadUserData());
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Account Section
                      _buildSection(
                        title: 'Account',
                        children: [
                          _buildProfileItem(
                            icon: Icons.email,
                            title: 'Email',
                            subtitle: _user?.email ?? 'No email provided',
                          ),
                          _buildProfileItem(
                            icon: Icons.phone,
                            title: 'Phone',
                            subtitle: _user?.phone ?? 'No phone provided',
                          ),
                          if (_user?.address != null)
                            _buildProfileItem(
                              icon: Icons.location_on,
                              title: 'Address',
                              subtitle: _user!.address!,
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Settings Section
                      _buildSection(
                        title: 'Settings',
                        children: [
                          _buildActionItem(
                            icon: Icons.security,
                            title: 'Change Password',
                            onTap: () {
                              // In a real app, navigate to change password screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Change Password feature not implemented')),
                              );
                            },
                          ),
                          _buildActionItem(
                            icon: Icons.description,
                            title: 'Terms and Conditions',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const KetentuanPage(),
                                ),
                              );
                            },
                          ),
                          _buildActionItem(
                            icon: Icons.help,
                            title: 'Help and Support',
                            onTap: () {
                              // In a real app, navigate to help screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Help feature not implemented')),
                              );
                            },
                          ),
                          _buildActionItem(
                            icon: Icons.exit_to_app,
                            title: 'Sign Out',
                            onTap: _signOut,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(
                builder: (_) {
                  if (index == 0) {
                    return _user?.userType == 'designer'
                        ? const DesignerHomePage()
                        : const ClientHomePage();
                  } else if (index == 1) {
                    return const OrderHistoryPage();
                  } else {
                    return const ChatListPage();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
  
  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blue),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}