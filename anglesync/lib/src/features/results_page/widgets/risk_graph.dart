import 'package:flutter/material.dart';

class RiskGraph extends StatelessWidget {
  const RiskGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text("Graph Here")),
    );
  }
}