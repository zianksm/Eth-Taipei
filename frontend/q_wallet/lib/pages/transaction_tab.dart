import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Auth import

class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key}); // No uid parameter

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  final storage = const FlutterSecureStorage();

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
    final walletAddress = '0x' + credentials.address.toString(); // Includes '0x'
    return {
      'address': walletAddress,
      'privateKey': storedPrivateKey,
    };
  }

  @override
  Widget build(BuildContext context) {
    const qGray = Color(0xFFF5F5F5);
    const buttonTextColor = Color(0xFF0055FF);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showTransferDialog(context),
                icon: const Icon(Icons.send, size: 20),
                label: const Text('Transfer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: buttonTextColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showReceiveDialog(context),
                icon: const Icon(Icons.arrow_downward, size: 20),
                label: const Text('Receive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: buttonTextColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Transaction 1: Buy
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: qGray,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[900]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_downward, color: Color(0xFF00F0FF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+0.025 BTC',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF00F0FF),
                            ),
                            softWrap: true,
                          ),
                          Text(
                            '@ \$42,350.00',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'RobotoMono',
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Today, 10:42 AM',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Transaction 2: Sell
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: qGray,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[900]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.arrow_upward, color: Colors.red[400], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '-0.0059 BTC',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red[400],
                            ),
                            softWrap: true,
                          ),
                          Text(
                            '@ \$42,372.88',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'RobotoMono',
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Yesterday, 4:15 PM',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    final emailController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (USDC)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text;
                final amount = amountController.text;
                if (email.isNotEmpty && amount.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transferring $amount USDC to $email'),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showReceiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Receive'),
          content: FutureBuilder<Map<String, String>?>(
            future: _getWalletDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error fetching wallet address');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Text('No wallet address found. Please sign in.');
              } else {
                final walletAddress = snapshot.data!['address']!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share this address to receive USDC:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      walletAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'RobotoMono',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                final walletDetails = await _getWalletDetails();
                if (walletDetails != null) {
                  // Placeholder for copy-to-clipboard logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address copied to clipboard')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }
}