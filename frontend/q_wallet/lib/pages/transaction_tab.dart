import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  final storage = const FlutterSecureStorage();
  bool _isOffRampActive = true; // Tracks active tab (Off-Ramp or On-Ramp)
  int _offRampStep = 1; // Tracks Off-Ramp flow step
  int _onRampStep = 1; // Tracks On-Ramp flow step

  Future<Map<String, String>?> _getWalletDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user signed in');
      return null;
    }
    final uid = user.uid;
    final storedPrivateKey = await storage.read(key: 'privateKey_$uid');
    if (storedPrivateKey == null) {
      print('No private key found in storage for UID: $uid');
      return null;
    }

    final credentials = EthPrivateKey.fromHex(storedPrivateKey);
    final walletAddress = '0x' + credentials.address.toString();
    return {
      'address': walletAddress,
      'privateKey': storedPrivateKey,
    };
  }

  @override
  Widget build(BuildContext context) {
    const qGray = Color(0xFFF5F5F5);
    const qAccent = Color(0xFF00F0FF);
    const buttonTextColor = Color(0xFF0055FF);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ramp Type Selection
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isOffRampActive = true;
                      _offRampStep = 1; // Reset to step 1
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOffRampActive ? qGray : Colors.white,
                    foregroundColor: buttonTextColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward, size: 20),
                      SizedBox(width: 8),
                      Text('Off-Ramp', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isOffRampActive = false;
                      _onRampStep = 1; // Reset to step 1
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isOffRampActive ? qGray : Colors.white,
                    foregroundColor: buttonTextColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward, size: 20),
                      SizedBox(width: 8),
                      Text('On-Ramp', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flow Container
          Expanded(
            child: _isOffRampActive ? _buildOffRampFlow(qGray, qAccent) : _buildOnRampFlow(qGray, qAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildOffRampFlow(Color qGray, Color qAccent) {
    switch (_offRampStep) {
      case 1: // Step 1: KYC Verification (Placeholder)
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blue[900]!.withOpacity(0.3),
                child: Icon(Icons.person, color: qAccent, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Complete KYC Verification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'To use Off-Ramp services, complete identity verification.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _offRampStep = 2), // Simulate KYC completion
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Start Verification', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      case 2: // Step 2: USDC Balance & Give Allowance
        return _buildOffRampStep2(qGray, qAccent);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOffRampStep2(Color qGray, Color qAccent) {
    final amountController = TextEditingController();
    final tokenController = TextEditingController(text: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'); // USDC

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.check, color: qAccent), const SizedBox(width: 8), const Text('KYC Verified')]),
          const SizedBox(height: 16),
          const Text('Give Allowance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black87,
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Available Balance:', style: TextStyle(color: Colors.grey)),
                    Text('1,245.89 USDC', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Network:', style: TextStyle(color: Colors.grey)),
                    Text('CELO', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount (USDC)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tokenController,
            decoration: const InputDecoration(labelText: 'Token Address', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                final amount = amountController.text;
                final token = tokenController.text;
                if (amount.isEmpty || token.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                  return;
                }

                final walletDetails = await _getWalletDetails();
                if (walletDetails == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load wallet details')));
                  return;
                }

                final key = walletDetails['privateKey']!;
                try {
                  final apiUrl = dotenv.env['ENS_API_URL'] ?? 'http://localhost:3000';
                  final response = await http.post(
                    Uri.parse('$apiUrl/give-allowance'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'key': key,
                      'token': token,
                      'amount': (double.parse(amount) * 1e6).toInt().toString(), // USDC has 6 decimals
                    }),
                  );

                  final result = jsonDecode(response.body);
                  if (response.statusCode == 200 && result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Allowance granted for $amount USDC')));
                    setState(() => _offRampStep = 1); // Reset or move to next step
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Allowance failed')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnRampFlow(Color qGray, Color qAccent) {
    switch (_onRampStep) {
      case 1: // Step 1: Become a Filler
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.purple[900]!.withOpacity(0.3),
                child: Icon(Icons.person_add, color: Colors.purple[400], size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Become a Liquidity Provider', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Earn money by providing liquidity for on-ramp transactions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _onRampStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Opt In As Filler', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      case 2: // Step 2: Open Order
        return _buildOnRampStep2(qGray, qAccent);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOnRampStep2(Color qGray, Color qAccent) {
    final addressController = TextEditingController();
    final amountController = TextEditingController();
    final tokenController = TextEditingController(text: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    final bankTypeController = TextEditingController(text: '0');
    final bankNumberController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Open Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount (USDC)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tokenController,
            decoration: const InputDecoration(labelText: 'Token Address', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bankTypeController,
            decoration: const InputDecoration(labelText: 'Bank Type (0 for WISE)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bankNumberController,
            decoration: const InputDecoration(labelText: 'Bank Number', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                final address = addressController.text;
                final amount = amountController.text;
                final token = tokenController.text;
                final bankType = bankTypeController.text;
                final bankNumber = bankNumberController.text;

                if (address.isEmpty || amount.isEmpty || token.isEmpty || bankType.isEmpty || bankNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                  return;
                }

                final walletDetails = await _getWalletDetails();
                if (walletDetails == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load wallet details')));
                  return;
                }

                final key = walletDetails['privateKey']!;
                final fillDeadline = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
                const orderDataType = '0x0000000000000000000000000000000000000000000000000000000000000000';

                final orderData = {
                  'token': token,
                  'amount': (double.parse(amount) * 1e6).toInt().toString(),
                  'bankType': int.parse(bankType),
                  'bankNumber': bankNumber,
                };

                try {
                  final apiUrl = dotenv.env['ENS_API_URL'] ?? 'http://localhost:3000';
                  final response = await http.post(
                    Uri.parse('$apiUrl/open-order'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'key': key,
                      'fillDeadline': fillDeadline,
                      'orderDataType': orderDataType,
                      'orderData': orderData,
                    }),
                  );

                  final result = jsonDecode(response.body);
                  if (response.statusCode == 200 && result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order opened for $amount USDC')));
                    setState(() => _onRampStep = 1); // Reset or move to next step
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order failed')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}