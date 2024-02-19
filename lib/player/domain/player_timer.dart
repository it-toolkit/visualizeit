

import 'dart:async';

class PlayerTimer {

  Timer? _timer;
  void Function()? _callback;
  bool _running = false;

  bool get isInitialized => _callback != null;

  void init(void Function() callback) {
    _callback = callback;
  }

  void start(){
    if (_callback == null) throw Exception("Timer not initialized");

    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) { if (_running) _callback?.call(); });
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