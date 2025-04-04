import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:q_wallet/pages/home_page.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // For utf8 encoding

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigningIn = false;
  static const _storage = FlutterSecureStorage();

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isSigningIn = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Generate EVM wallet using UID
        final walletData = _generateWalletFromUid(user.uid);
        final walletAddress = walletData['address']!;
        final privateKey = walletData['privateKey']!;

        // Optionally store the private key securely
        await _storage.write(key: 'privateKey_${user.uid}', value: privateKey);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WalletHomePage(
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Map<String, String> _generateWalletFromUid(String uid) {
    // Use UID as seed to generate a deterministic private key
    final seed = utf8.encode(uid); // Convert UID to bytes
    final privateKeyBytes = web3.keccak256(seed); // 32-byte private key
    final privateKey = web3.bytesToHex(privateKeyBytes, include0x: true); // Hex string with 0x
    final credentials = web3.EthPrivateKey(privateKeyBytes); // Create from bytes
    final walletAddress = credentials.address.toString(); // Get address as hex string

    return {
      'privateKey': privateKey,
      'address': walletAddress,
    };
  }

  @override
  Widget build(BuildContext context) {
    const Color qBlack = Color(0xFF0A0A0A);
    const Color qWhite = Color(0xFFF8F8F8);
    const Color qGray = Color(0xFF1A1A1A);
    const Color qPrimary = Color(0xFF0055FF);
    const Color qAccent = Color(0xFF00F0FF);

    return Scaffold(
      backgroundColor: qBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [qPrimary, qAccent],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Q WALLET',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: qWhite,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              const Text(
                'Commodity Finance',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: qWhite,
                  fontFamily: 'Inter',
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [qPrimary, qAccent],
                ).createShader(bounds),
                child: const Text(
                  'Reinvented',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: qWhite,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'The protocol that transforms invoices into working capital. Secure, efficient, and built for the modern commodity trader.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _isSigningIn ? null : () => _signInWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    foregroundColor: MaterialStateProperty.all(qBlack),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [qPrimary, qAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSigningIn)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(qBlack),
                            ),
                          )
                        else
                          const FaIcon(FontAwesomeIcons.google, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Login with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: qBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: qGray, width: 2),
                            color: qGray,
                          ),
                          child: const Center(
                            child: Text(
                              '.eth',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'RobotoMono',
                                color: qWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 104,
                        ),
                        child: const Text(
                          'Trusted by institutional traders and suppliers',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}