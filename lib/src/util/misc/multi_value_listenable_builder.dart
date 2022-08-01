import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiValueListenableBuilder extends StatelessWidget {
  const MultiValueListenableBuilder({
    required this.valueListenables,
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

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
