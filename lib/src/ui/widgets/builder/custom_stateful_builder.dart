import 'package:flutter/material.dart';

typedef DisposerCallback = void Function();

class CustomStatefulBuilder extends StatefulWidget {
  final StatefulWidgetBuilder builder;
  final DisposerCallback dispose;

  const CustomStatefulBuilder(
      {Key? key, required this.builder, required this.dispose})
      : super(key: key);

  @override
  _CustomStatefulBuilderState createState() => _CustomStatefulBuilderState();
}

class _CustomStatefulBuilderState extends State<CustomStatefulBuilder> {
  @override
  Widget build(BuildContext context) =>
      widget.builder(context, (void Function() fn) {
        if (mounted) setState(fn);
      });

  @override
  void dispose() {
    super.dispose();
    widget.dispose();
  }
}
