import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MultiValueListenableBuilder extends StatelessWidget {
  const MultiValueListenableBuilder({
    super.key,
    required this.valueListenables,
    required this.builder,
    this.child,
  });

  final List<ValueListenable> valueListenables;
  final Widget Function(BuildContext context, List<dynamic> values, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _getBuilder(0);
  }

  ValueListenableBuilder _getBuilder(int count) {
    return ValueListenableBuilder(
      valueListenable: valueListenables[count],
      builder: (context, value, __) {
        // If there is at least one more in the list, go another round, else return with builder function
        return count + 1 < valueListenables.length
            ? _getBuilder(count + 1)
            : builder(context, valueListenables.map((e) => e.value).toList(growable: false), child);
      },
    );
  }
}
