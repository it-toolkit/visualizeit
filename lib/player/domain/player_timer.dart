

import 'dart:async';

import 'package:visualizeit_extensions/logging.dart';

final _logger = Logger("player.timer");

class PlayerTimer {
  static const DefaultFrameDurationInMillis = 1000;

  Timer? _timer;
  void Function()? _callback;
  bool _running = false;
  int _frameDurationInMillis = DefaultFrameDurationInMillis;
  double _speedFactor = 1.0;

  bool get running => _running;
  Duration get frameDuration => Duration(milliseconds: (_frameDurationInMillis / _speedFactor).round());

  bool get isInitialized => _callback != null;

  double get speedFactor => _speedFactor;

  void init(void Function() callback) {
    _callback = callback;
  }

  set baseFrameDurationInMillis(int value) {
    if (value == _frameDurationInMillis) return;

    _frameDurationInMillis = value;
    _logger.trace(() => "Base frame duration updated to $value ms");
    if(_timer != null) {
      stop();
      start();
    }
  }

  void changeSpeed(double speedFactor) {
    _speedFactor = speedFactor;
    if(_timer != null) {
      stop();
      start();
    }
  }

  void start(){
    if (_callback == null) throw Exception("Timer not initialized");

    _timer ??= Timer.periodic(frameDuration, (timer) { if (_running) _callback?.call(); });
    _running = true;
  }

  void pause(){
    _running = false;
  }

  void reset(){
    _running = false;
  }

  bool toggle() {
    _running = !_running;
    return _running;
  }

  void stop(){
    _running = false;
    _timer?.cancel();
    _timer = null;
  }
}