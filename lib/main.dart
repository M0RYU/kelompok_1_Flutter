import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'screens/splash/splashscreen.dart';
import 'services/auth_service.dart';
import 'services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = ConfigService();

  // Initialize Firebase with the options specific to this platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check for enhanced security
  await FirebaseAppCheck.instance.activate(
    // Use different providers based on platform - for development, we'll use debug provider
    // In production you'd typically use:
    // * androidProvider: AndroidProvider.playIntegrity 
    // * appleProvider: AppleProvider.appAttest, 
    // * webProvider: ReCaptchaV3Provider(reCaptchaV3SiteKey)
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigService>(create: (_) => configService),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kreatif Design',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}