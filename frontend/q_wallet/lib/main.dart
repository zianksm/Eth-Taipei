import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:q_wallet/pages/home_page.dart';
import 'package:q_wallet/pages/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  static const _storage = FlutterSecureStorage();

  Future<Widget> _getInitialPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final privateKey = await _storage.read(key: 'privateKey_${user.uid}');
      final ensName = await _storage.read(key: 'ensName_${user.uid}');
      if (privateKey != null && ensName != null) {
        return const WalletHomePage();
      }
    }
    return const LoginPage();
  }

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
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading screen while checking storage
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            // Handle errors (e.g., storage access failure)
            return const Scaffold(
              body: Center(child: Text('Error initializing app')),
            );
          }
          // Return the determined initial page
          return snapshot.data ?? const LoginPage();
        },
      ),
    );
  }
}