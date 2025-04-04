import 'package:flutter/material.dart';
import 'package:q_wallet/pages/home_page.dart';

void main() {
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
      home: const WalletHomePage(),
    );
  }
}