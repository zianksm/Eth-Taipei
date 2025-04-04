import 'package:flutter/material.dart';

class EmptyTabPage extends StatelessWidget {
  final String tabName;

  const EmptyTabPage({super.key, required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$tabName Tab\n(Empty)',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}