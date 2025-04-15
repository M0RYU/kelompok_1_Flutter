import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../auth/login_page.dart';
import '../../services/auth_service.dart';
import '../home/client_home_page.dart';
import '../home/designer_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    // Get device screen size for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final logoSize = screenSize.width * 0.35; // 35% of screen width
    final maxLogoSize = 150.0; // Maximum logo size
    final finalLogoSize = logoSize > maxLogoSize ? maxLogoSize : logoSize;

    return AnimatedSplashScreen(
      splash: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 2000),
        builder: (context, value, child) {
          // Combine multiple animations
          final scale = 0.8 + (value * 0.2); // Smooth scaling from 0.8 to 1.0
          final rotation = value * 2 * math.pi; // Full rotation
          final opacity = value; // Fade in effect

          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            ),
          );
        },
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
      backgroundColor: const Color(0xFFF5F5F5),
      splashIconSize: finalLogoSize,
      duration: 2500, // 2.5 seconds
      splashTransition: SplashTransition.scaleTransition, // Smooth scaling transition
      pageTransitionType: PageTransitionType.fade, // Fade transition to the next screen
      nextScreen: FutureBuilder<bool>(
        future: Provider.of<AuthService>(context, listen: false).autoSignIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Jika auto login berhasil, cek tipe user dan arahkan ke halaman yang sesuai
            if (snapshot.data == true) {
              // Tampilkan loading widget sementara menunggu data user
              return FutureBuilder(
                future: Provider.of<AuthService>(context, listen: false).getCurrentUserData(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.data != null) {
                    final userData = userSnapshot.data!;
                    
                    // Navigasi berdasarkan tipe user
                    if (userData.userType == 'designer') {
                      return const DesignerHomePage();
                    } else {
                      return const ClientHomePage();
                    }
                  }
                  
                  // Selama menunggu data user, tampilkan indikator loading
                  return Scaffold(
                    backgroundColor: const Color(0xFFF5F5F5),
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );
            } else {
              // Jika auto login gagal, arahkan ke LoginPage
              return const LoginPage();
            }
          } 
          // Selama proses, tetap menampilkan splash screen
          return const SizedBox();
        },
      ),
    );
  }
}