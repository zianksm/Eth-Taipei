import 'package:flutter/material.dart';
import 'package:q_wallet/widgets/balance_card.dart';
import 'package:q_wallet/widgets/credit_expiration_card.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            BalanceCard(),
            SizedBox(height: 24),
            CreditExpirationCard(),
          ],
        ),
      ),
    );
  }
}