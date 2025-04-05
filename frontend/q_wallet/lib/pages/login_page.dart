import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:q_wallet/pages/home_page.dart';
import 'package:q_wallet/pages/webview_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:http/http.dart' as http;
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

  Future<List<String>> _fetchEnsNames(String address) async {
    try {
      final apiUrl = dotenv.env['ENS_API_URL'] ?? 'http://localhost:3000';
      final url = Uri.parse('$apiUrl/ens/$address');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ensName = data['ensName'] as String;
        return ensName.isEmpty ? [] : [ensName];
      } else {
        print('ENS API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching ENS names: $e');
      return [];
    }
  }

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

        // Fetch ENS names
        final ensNames = await _fetchEnsNames(walletAddress);
        String? selectedEns;

        if (ensNames.isNotEmpty && mounted) {
          // Show dialog to choose ENS
          selectedEns = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Select Your ENS Name'),
              content: SingleChildScrollView(
                child: Column(
                  children: ensNames.map((name) => ListTile(
                    title: Text(name),
                    onTap: () => Navigator.pop(context, name),
                  )).toList()..add(ListTile(
                    title: const Text('Buy a new one'),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebviewPage(privateKey: privateKey)
                      ),
                    ),
                  )),
                ),
              ),
            ),
          );
        }else{
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WebviewPage(privateKey: privateKey)
              ),
            );
          }
        }

        // Store private key and selected ENS
        await _storage.write(key: 'privateKey_${user.uid}', value: privateKey);
        if (selectedEns != null && selectedEns.isNotEmpty) {
          await _storage.write(key: 'ensName_${user.uid}', value: selectedEns);
          // Navigate to WalletHomePage only if ENS is selected and stored
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const WalletHomePage(),
              ),
            );
          }
        } else if (mounted) {
          // If no ENS is selected, go to WebviewPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WebviewPage(privateKey: privateKey),
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
    final walletAddress = '0x' + credentials.address.toString(); // Get address as hex string

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
                'Qwallet is an Ofac Compliant P2P On/Off Ramp Orderbook Deployed on CELO.',
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
                          maxWidth: MediaQuery.of(context).size.width - 104, // Adjust for padding and icon
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
