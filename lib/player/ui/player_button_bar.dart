import 'package:flutter/material.dart';

class PlayerButtonBar extends StatelessWidget {
  final VoidCallback? onRestartPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onPlayPausePressed;
  final VoidCallback? onNextPressed;
  final VoidCallback? onFullscreenPressed;
  final double progress; // Value between 0.0 and 1.0 for the progress bar

  const PlayerButtonBar({
    super.key,
    this.onRestartPressed,
    this.onPreviousPressed,
    this.onPlayPausePressed,
    this.onNextPressed,
    this.onFullscreenPressed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200], // Adjust as needed
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.restart_alt), onPressed: onPreviousPressed),
          IconButton(icon: const Icon(Icons.skip_previous), onPressed: onPreviousPressed),
          IconButton(icon: const Icon(Icons.play_arrow), onPressed: onPlayPausePressed),
          IconButton(icon: const Icon(Icons.skip_next), onPressed: onNextPressed),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[400],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.fullscreen), onPressed: onFullscreenPressed),
        ],
      ),
    );
  }
}
