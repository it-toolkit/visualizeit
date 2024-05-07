import 'package:flutter/material.dart';

class PlayerButtonBar extends StatelessWidget {
  final VoidCallback? onRestartPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onPlayPausePressed;
  final VoidCallback? onNextPressed;
  final VoidCallback? onFullscreenPressed;
  final Function(double)? onSpeedChanged;
  final double progress; // Value between 0.0 and 1.0 for the progress bar
  final bool isPlaying;
  const PlayerButtonBar({
    super.key,
    this.onRestartPressed,
    this.onPreviousPressed,
    this.onPlayPausePressed,
    this.onNextPressed,
    this.onFullscreenPressed,
    this.onSpeedChanged,
    required this.progress,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200], // Adjust as needed
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.restart_alt), onPressed: onRestartPressed),
          IconButton(icon: const Icon(Icons.skip_previous), onPressed: onPreviousPressed),
          IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: onPlayPausePressed),
          IconButton(icon: const Icon(Icons.skip_next), onPressed: onNextPressed),
          SpeedSelector(onSpeedChanged: onSpeedChanged),
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

class SpeedSelector extends StatefulWidget {
  final Function(double)? onSpeedChanged;

  const SpeedSelector({Key? key, this.onSpeedChanged}) : super(key: key);

  @override
  _SpeedSelectorState createState() => _SpeedSelectorState();
}

class _SpeedSelectorState extends State<SpeedSelector> {
  double _currentSpeed = 1.0;  // Default speed
  final List<double> _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 4.0];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<double>(
      value: _currentSpeed,
      icon: Icon(Icons.speed),
      iconEnabledColor: Colors.black,
      onChanged: (double? newValue) {
        setState(() {
          _currentSpeed = newValue!;
          widget.onSpeedChanged?.call(_currentSpeed);
        });
      },
      items: _speeds.map<DropdownMenuItem<double>>((double value) {
        return DropdownMenuItem<double>(
          value: value,
          child: Text("${value}x"),
        );
      }).toList(),
    );
  }
}
