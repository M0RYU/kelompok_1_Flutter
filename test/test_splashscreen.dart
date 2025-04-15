import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'test_login_page.dart';
import '../lib/services/auth_service.dart';
import 'test_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    
    // Start checking auth after animation plays for a bit
    Future.delayed(const Duration(milliseconds: 1000), _checkAuthAndNavigate);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkAuthAndNavigate() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Check if there's a current user (already logged in)
    if (authService.currentUser != null) {
      if (!mounted) return;
      _navigateToHomePage();
      return;
    }
    
    // Try auto sign-in with saved credentials
    final success = await authService.autoSignIn();
    
    if (!mounted) return;
    
    // Wait for a minimum time to show the splash screen
    final elapsed = DateTime.now().difference(DateTime.now().subtract(const Duration(milliseconds: 1000)));
    if (elapsed < const Duration(milliseconds: 1500)) {
      await Future.delayed(const Duration(milliseconds: 1500) - elapsed);
    }
    
    if (success) {
      _navigateToHomePage();
    } else {
      // No auto-login, go to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
  
  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get device screen size for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final logoSize = screenSize.width * 0.35; // 35% of screen width
    final maxLogoSize = 150.0; // Maximum logo size
    final finalLogoSize = logoSize > maxLogoSize ? maxLogoSize : logoSize;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Combine multiple animations
            final scale = 0.8 + (_animation.value * 0.2); // Smooth scaling from 0.8 to 1.0
            final rotation = _animation.value * 2 * math.pi; // Full rotation
            final opacity = _animation.value; // Fade in effect

            return Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotation,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: finalLogoSize,
                    height: finalLogoSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/Logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}