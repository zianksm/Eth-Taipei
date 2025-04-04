import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:q_wallet/pages/home_page.dart';
import 'package:q_wallet/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A2BE2),
          primary: const Color(0xFF8A2BE2),
          secondary: const Color(0xFF4169E1),
        ),
        useMaterial3: true,
      ),
      // Dynamically set the home page based on auth state
      home: FirebaseAuth.instance.currentUser != null
          ? const WalletHomePage()
          : const LoginPage(),
    );
  }
}