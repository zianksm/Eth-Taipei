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
            // Add more widgets here if needed (e.g., Recent Transactions)
          ],
        ),
      ),
    );
  }
}