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
  bool _isOffRampActive = true;
  int _offRampStep = 1;
  int _onRampStep = 1;
  bool _isKycVerified = false;
  Map<String, dynamic>? _currentOrderData; // Store order data for later steps

  @override
  void initState() {
    super.initState();
    _loadKycState();
  }

  Future<void> _loadKycState() async {
    final storedKyc = await storage.read(key: 'kyc_verified');
    if (storedKyc == 'true') {
      setState(() {
        _isKycVerified = true;
      });
    }
  }

  Future<void> _saveKycState() async {
    await storage.write(key: 'kyc_verified', value: 'true');
  }

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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _isOffRampActive = true;
                    _offRampStep = 1;
                  }),
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
                  onPressed: () => setState(() {
                    _isOffRampActive = false;
                    _onRampStep = 1;
                  }),
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
          Expanded(
            child: _isOffRampActive ? _buildOffRampFlow(qGray, qAccent) : _buildOnRampFlow(qGray, qAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildOffRampFlow(Color qGray, Color qAccent) {
    switch (_offRampStep) {
      case 1: // Step 1: KYC Verification or KYC Verified with Give Allowance
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
              if (_isKycVerified) ...[
                Row(
                  children: [
                    Icon(Icons.check, color: qAccent),
                    const SizedBox(width: 8),
                    const Text('KYC Verified'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _offRampStep = 2), // Move to Give Allowance
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Give Allowance', style: TextStyle(color: Colors.black)),
                ),
              ] else ...[
                const Text(
                  'To use Off-Ramp services, complete identity verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isKycVerified = true; // Mark KYC as verified
                      _saveKycState(); // Persist the state
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start Verification', style: TextStyle(color: Colors.black)),
                ),
              ],
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
                    setState(() => _offRampStep = 1); // Reset to Step 1
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

      case 3: // Step 3: Waiting for Orders
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Icon(Icons.notifications, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Waiting for Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'You’ll receive a notification when a user requests an on-ramp transaction.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status:', style: TextStyle(color: Colors.white)), // White text
                        Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Earnings Potential:', style: TextStyle(color: Colors.white)), // White text
                        Text('~\$5/day', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), // White text
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _onRampStep = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Pause', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

      case 4: // Step 4: New Order Received
        return _buildOnRampStep4(qGray, qAccent);

      case 5: // Step 5: Make Transfer (Payment Confirmation)
        return _buildOnRampStep5(qGray, qAccent);

      case 6: // Step 6: Waiting for Proof
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              CircularProgressIndicator(color: qAccent),
              const SizedBox(height: 16),
              const Text('Waiting for Proof', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'We’re verifying your transfer. This usually takes a few minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:', style: TextStyle(color: Colors.white)), // White text
                        Text(
                          '${_currentOrderData?['amount'] ?? '0'} USD',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono', color: Colors.white), // White text
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status:', style: TextStyle(color: Colors.white)), // White text
                        Text('Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You’ll receive USDC once verified',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );

      case 7: // Step 7: Transfer Complete
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('Transaction Complete', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'You’ve earned 20.00 USDC for this transaction!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount Sent:', style: TextStyle(color: Colors.white)), // White text
                        Text(
                          '${_currentOrderData?['amount'] ?? '0'} USD',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono', color: Colors.white), // White text
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('USDC Received:', style: TextStyle(color: Colors.white)), // White text
                        Text(
                          '980.00 USDC',
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono', color: Colors.white), // White text
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fee Earned:', style: TextStyle(color: Colors.white)), // White text
                        Text(
                          '+20.00 USDC',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'RobotoMono'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _onRampStep = 3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Accept New Order', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _onRampStep = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );

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

                _currentOrderData = {
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
                      'orderData': _currentOrderData,
                    }),
                  );

                  final result = jsonDecode(response.body);
                  if (response.statusCode == 200 && result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order opened for $amount USDC')));
                    setState(() => _onRampStep = 3);
                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() => _onRampStep = 4);
                    });
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

  Widget _buildOnRampStep4(Color qGray, Color qAccent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Order Received', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount:', style: TextStyle(color: Colors.white)), // White text
                    Text(
                      '1,000.00 USD',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono', color: Colors.white), // White text
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Receive:', style: TextStyle(color: Colors.white)), // White text
                    Text(
                      '980.00 USDC',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono', color: Colors.white), // White text
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('User Email:', style: TextStyle(color: Colors.white)), // White text
                    Text(
                      'user@example.com',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // White text
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fee Earned:', style: TextStyle(color: Colors.white)), // White text
                    Text(
                      '20.00 USDC',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'RobotoMono'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _onRampStep = 3),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reject', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _onRampStep = 5),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnRampStep5(Color qGray, Color qAccent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: qGray, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Make Transfer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Please transfer 1,000.00 USD to the following Wise account:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recipient:', style: TextStyle(color: Colors.white)), // White text
                    Text(
                      'Q Wallet Inc.',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // White text
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account Number:', style: TextStyle(color: Colors.white)), // White text
                    Text(
                      '123456789',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // White text
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reference:', style: TextStyle(color: Colors.white)), // White text
                    Text(
                      'TX-987654',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'RobotoMono', color: Colors.white), // White text
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final walletDetails = await _getWalletDetails();
              if (walletDetails == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load wallet details')));
                return;
              }

              setState(() => _onRampStep = 6);
              Future.delayed(const Duration(seconds: 2), () {
                setState(() => _onRampStep = 7);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('I’ve Made Transfer', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}