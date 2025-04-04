import 'package:flutter/material.dart';
import 'package:q_wallet/pages/empty_tab_page.dart';
import 'package:q_wallet/pages/wallet_tab.dart';

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showLeading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, initialIndex: 0, vsync: this); // Changed to 0
    _tabController.addListener(() {
      setState(() {
        _showLeading = _tabController.index != 2;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8A2BE2), Color(0xFF4169E1), Color(0xFFFF69B4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Q Wallet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          EmptyTabPage(tabName: 'Home'),
          EmptyTabPage(tabName: 'Stats'),
          WalletTab(),
          EmptyTabPage(tabName: 'Transfer'),
          EmptyTabPage(tabName: 'Profile'),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8A2BE2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF8A2BE2),
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.show_chart)),
            Tab(icon: Icon(Icons.account_balance_wallet)),
            Tab(icon: Icon(Icons.swap_horiz)),
            Tab(icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}