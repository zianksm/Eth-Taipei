import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:q_wallet/widgets/balance_card.dart'; // Ensure this path is correct

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  Future<Map<String, String>?> _loadWalletData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found');
      return null;
    }

    const storage = FlutterSecureStorage();
    final uid = user.uid;
    final storedPrivateKey = await storage.read(key: 'privateKey_$uid');
    if (storedPrivateKey == null) {
      print('No private key found in storage for UID: $uid');
      return null;
    }

    final credentials = web3.EthPrivateKey.fromHex(storedPrivateKey);
    final walletAddress = '0x' + credentials.address.toString();
    return {
      'address': walletAddress,
      'privateKey': storedPrivateKey,
    };
  }

  @override
  Widget build(BuildContext context) {
    const qAccent = Color(0xFF00F0FF);
    const qGray = Color(0xFFF5F5F5);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, String>?>(
              future: _loadWalletData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Loading wallet data...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text(
                    'No wallet data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                final walletData = snapshot.data!;
                return BalanceCard(
                  walletAddress: walletData['address']!,
                  privateKey: walletData['privateKey']!,
                );
              },
            ),
            const SizedBox(height: 24),

            // Recent Transactions Section
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
                        child: const Icon(Icons.arrow_downward, color: qAccent, size: 20),
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
                                color: qAccent,
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
      ),
    );
  }
}