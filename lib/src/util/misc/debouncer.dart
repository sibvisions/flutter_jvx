import 'dart:async';

class Debounce {
  Debounce({
    this.delay = const Duration(milliseconds: 300),
  });

  final Duration delay;
  Timer? _timer;

  void call(void Function() callback) {
    if (_timer == null) {
      callback.call();
    }
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel(); // You can comment-out this line if you want. I am not sure if this call brings any value.
    _timer = null;
  }
}
