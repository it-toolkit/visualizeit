import 'package:flutter/material.dart';

class CanvasWidget extends StatelessWidget {
  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue.shade100),
      child: const Center(
        child: Icon(
          Icons.play_circle,
          size: 48,
        ),
      ),
    );
  }
}
