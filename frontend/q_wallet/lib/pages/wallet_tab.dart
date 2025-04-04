import 'package:flutter/material.dart';
import 'package:q_wallet/widgets/balance_card.dart';
import 'package:q_wallet/widgets/credit_expiration_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:firebase_auth/firebase_auth.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

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
    final walletAddress = credentials.address.toString(); // Hex address
    return {
      'privateKey': storedPrivateKey,
      'address': walletAddress,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const BalanceCard(),
            const SizedBox(height: 24),
            const CreditExpirationCard(),
            const SizedBox(height: 24),
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
                final walletAddress = walletData['address']!;
                final privateKey = walletData['privateKey']!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Address: $walletAddress',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Private Key: $privateKey',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Warning: Do not share your private key!',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}