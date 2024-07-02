import 'package:flutter/material.dart';
import 'package:visualizeit/common/utils/extensions.dart';

class PlayerButtonBar extends StatelessWidget {
  final VoidCallback? onRestartPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onPlayPausePressed;
  final VoidCallback? onNextPressed;
  final VoidCallback? onFullscreenPressed;
  final Function(double)? onSpeedChanged;
  final Function(double)? onScaleChanged;
  final double progress; // Value between 0.0 and 1.0 for the progress bar
  final bool isPlaying;
  final double? speedFactor;
  final double? scale;
  final int baseFrameDurationMillis;

  const PlayerButtonBar({
    super.key,
    this.onRestartPressed,
    this.onPreviousPressed,
    this.onPlayPausePressed,
    this.onNextPressed,
    this.onFullscreenPressed,
    this.onSpeedChanged,
    this.onScaleChanged,
    required this.progress,
    required this.isPlaying,
    required this.speedFactor,
    required this.scale,
    required this.baseFrameDurationMillis
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey[200], // Adjust as needed
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.restart_alt), onPressed: onRestartPressed?.takeIf(!isPlaying)),
              IconButton(icon: const Icon(Icons.skip_previous), onPressed: onPreviousPressed?.takeIf(!isPlaying)),
              IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: onPlayPausePressed),
              IconButton(icon: const Icon(Icons.skip_next), onPressed: onNextPressed?.takeIf(!isPlaying)),
              LimitedBox(
                  maxWidth: 120,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[400],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              SpeedSelector(speedFactor ?? 1, onSpeedChanged: onSpeedChanged, baseFrameDurationMillis: baseFrameDurationMillis),
              CanvasScaleSelector(scale ?? 1, onScaleChanged: onScaleChanged),
              IconButton(icon: const Icon(Icons.fullscreen), onPressed: onFullscreenPressed),
            ])
          ],
        ));
  }
}

class SpeedSelector extends StatefulWidget {
  final double initialValue;
  final Function(double)? onSpeedChanged;
  final int baseFrameDurationMillis;

  const SpeedSelector(this.initialValue, {Key? key, this.onSpeedChanged, this.baseFrameDurationMillis = 1000}) : super(key: key);

  @override
  _SpeedSelectorState createState() => _SpeedSelectorState();
}

class _SpeedSelectorState extends State<SpeedSelector> {
  late double _currentSpeed;  // Default speed
  final List<double> _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 4.0];

  @override
  void initState() {
    _currentSpeed = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
        maxWidth: 100,
        child: DropdownButtonFormField<double>(
          alignment: AlignmentDirectional.center,
          menuMaxHeight: 200,
          isDense: true,
          value: _currentSpeed,
          iconEnabledColor: Colors.black,
          decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.speed)),
          items: _speeds.map<DropdownMenuItem<double>>((double value) {
            return DropdownMenuItem<double>(
              alignment: AlignmentDirectional.center,
              value: value,
              child: Tooltip(
                message: '${(widget.baseFrameDurationMillis / (1000 * value)).toStringAsPrecision(2)} seconds per frame',
                child: Text("${value}x", textScaler: TextScaler.linear(0.8)),
              ),
            );
          }).toList(),
          onChanged: widget.onSpeedChanged == null ? null : (double? newValue) {
              setState(() {
                _currentSpeed = newValue!;
                widget.onSpeedChanged?.call(_currentSpeed);
              });
          },
        ),
    );
  }
}

class CanvasScaleSelector extends StatefulWidget {
  final double initialValue;
  final Function(double)? onScaleChanged;

  const CanvasScaleSelector(this.initialValue, {Key? key, this.onScaleChanged}) : super(key: key);

  @override
  _CanvasScaleSelectorState createState() => _CanvasScaleSelectorState();
}

class _CanvasScaleSelectorState extends State<CanvasScaleSelector> {
  late double _currentScale;  // Default speed
  final List<double> _scales = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 4];

  @override
  void initState() {
    _currentScale = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: 100,
      child: DropdownButtonFormField<double>(
        alignment: AlignmentDirectional.center,
        menuMaxHeight: 200,
        isDense: true,
        value: _currentScale,
        iconEnabledColor: Colors.black,
        decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.photo_size_select_large_outlined)),
        items: _scales.map<DropdownMenuItem<double>>((double value) {
          return DropdownMenuItem<double>(
            alignment: AlignmentDirectional.center,
            value: value,
            child: Tooltip(
              message: '${value}x scaled canvas',
              child: Text("${value}x", textScaler: TextScaler.linear(0.8)),
            ),
          );
        }).toList(),
        onChanged: widget.onScaleChanged == null ? null : (double? newValue) {
          setState(() {
            _currentScale = newValue!;
            widget.onScaleChanged?.call(_currentScale);
          });
        },
      ),
    );
  }
}