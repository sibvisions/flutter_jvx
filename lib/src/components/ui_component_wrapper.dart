import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';

class UiComponentWrapper extends StatefulWidget {
  const UiComponentWrapper({
    required this.model,
    Key? key
  }) : super(key: key);

  final UiComponentModel model;

  @override
  _UiComponentWrapperState createState() => _UiComponentWrapperState();
}

class _UiComponentWrapperState extends State<UiComponentWrapper> {


  @override
  Widget build(BuildContext context) {
    return Row(
      key: widget.key,
      children: const [
        Text("asdasd")
      ],
    );
  }
}
