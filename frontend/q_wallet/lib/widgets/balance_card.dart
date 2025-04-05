import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class BalanceCard extends StatefulWidget {
  final String walletAddress;
  final String privateKey;

  const BalanceCard({
    super.key,
    required this.walletAddress,
    required this.privateKey,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isPrivateKeyVisible = false;

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maskedAddress = '${widget.walletAddress.substring(0, 6)}...${widget.walletAddress.substring(widget.walletAddress.length - 4)}';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0055FF), Color(0xFF00F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BE2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Available Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '\$1,245.00', // Static; replace with real data if needed
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Wallet Address with Copy Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet Address',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    maskedAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: 'Copy Wallet Address',
                child: IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                  onPressed: () => _copyToClipboard(widget.walletAddress, 'Wallet Address copied!'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Private Key with Eye Icon and Copy Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _isPrivateKeyVisible ? widget.privateKey : '•••• •••• •••• ••••',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'RobotoMono',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  if (_isPrivateKeyVisible) // Show copy button only when visible
                    Tooltip(
                      message: 'Copy Private Key',
                      child: IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                        onPressed: () => _copyToClipboard(widget.privateKey, 'Private Key copied!'),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _isPrivateKeyVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPrivateKeyVisible = !_isPrivateKeyVisible;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const Text(
            'Warning: Do not share your private key!',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }
}