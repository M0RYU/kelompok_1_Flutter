import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash/splashscreen.dart';
import 'screens/auth/login_page.dart';
import 'screens/home/client_home_page.dart';
import 'screens/home/designer_home_page.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'KRESIGN - Kreatif Design',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[100],
          fontFamily: 'Poppins',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show the splash screen which will handle auth checks
    return const SplashScreen();
  }
}

class AuthStateChecker extends StatelessWidget {
  const AuthStateChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (user == null) {
            // User is not signed in, show login page
            return const LoginPage();
          }

          // User is signed in, check user type and redirect accordingly
          return FutureBuilder<UserType>(
            future: _getUserType(context, user.uid),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Redirect based on user type
              if (userTypeSnapshot.data == UserType.designer) {
                return const DesignerHomePage();
              } else {
                return const ClientHomePage();
              }
            },
          );
        }

        // Connection waiting
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<UserType> _getUserType(BuildContext context, String uid) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    if (userData?.userType == 'designer') {
      return UserType.designer;
    } else {
      return UserType.client;
    }
  }
}

enum UserType { client, designer }