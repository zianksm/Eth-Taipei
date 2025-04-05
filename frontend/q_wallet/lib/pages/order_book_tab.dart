import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class OrderBookTab extends StatefulWidget {
  const OrderBookTab({super.key});

  @override
  State<OrderBookTab> createState() => _OrderBookTabState();
}

class _OrderBookTabState extends State<OrderBookTab> {
  // Define colors for light mode
  static const lightGray = Color(0xFFF5F5F5);
  static const qAccent = Color(0xFF00F0FF);
  static const qBlack = Color(0xFF0A0A0A);
  static const qPrimary = Color(0xFF0055FF);

  // Initial order data adjusted to new range (83000 - 85000), removed 'total'
  List<Map<String, dynamic>> sellOrders = [
    {'price': 84900.00, 'amount': 0.125},
    {'price': 84850.50, 'amount': 0.085},
    {'price': 84825.25, 'amount': 0.210},
  ];

  List<Map<String, dynamic>> buyOrders = [
    {'price': 84750.00, 'amount': 0.175},
    {'price': 84725.75, 'amount': 0.095},
    {'price': 84650.00, 'amount': 0.320},
    {'price': 84600.50, 'amount': 0.150},
  ];

  double marketPrice = 84756.80; // Adjusted initial market price

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          updateOrders();
        });
      }
    });
  }

  void updateOrders() {
    final random = Random();
    sellOrders = sellOrders.map((order) {
      final priceChange = (random.nextDouble() - 0.5) * 20;
      final newPrice = (order['price'] as double) + priceChange;
      final amount = order['amount'] as double;
      return {
        'price': newPrice.clamp(83000, 85000),
        'amount': amount,
      };
    }).toList()
      ..sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));

    buyOrders = buyOrders.map((order) {
      final priceChange = (random.nextDouble() - 0.5) * 20;
      final newPrice = (order['price'] as double) + priceChange;
      final amount = order['amount'] as double;
      return {
        'price': newPrice.clamp(83000, 85000),
        'amount': amount,
      };
    }).toList()
      ..sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));

    marketPrice = ((sellOrders.last['price'] as double) + (buyOrders.first['price'] as double)) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BTC/USDT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoMono',
                    color: qBlack,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_alt, color: Colors.grey),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pricing Board Container (with headers inside)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Order Book Header (Price and Amount only, centered)
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Price (USDT)',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Amount (BTC)',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sell Orders (Asks)
                  ...sellOrders.map((order) => _buildOrderRow(
                        order['price'].toStringAsFixed(2),
                        order['amount'].toStringAsFixed(3),
                        Colors.red[400]!,
                      )),

                  // Buy Orders (Bids)
                  ...buyOrders.map((order) => _buildOrderRow(
                        order['price'].toStringAsFixed(2),
                        order['amount'].toStringAsFixed(3),
                        qAccent,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Create Order Form
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[900]!.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Buy', style: TextStyle(color: qAccent, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900]!.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Sell', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildInputField('Price (USDT)', marketPrice.toStringAsFixed(2)),
                const SizedBox(height: 12),

                _buildInputField('Amount (BTC)', '0.00'),
                const SizedBox(height: 12),

                _buildInputField('Total (USDT)', '0.00'),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [qPrimary, qAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      'Place Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for order rows (removed total)
  Widget _buildOrderRow(String price, String amount, Color priceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                price,
                textAlign: TextAlign.left, // Centered price
                style: TextStyle(
                  color: priceColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
            Expanded(
              child: Text(
                amount,
                textAlign: TextAlign.right, // Centered amount
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for input fields
  Widget _buildInputField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'RobotoMono'),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}