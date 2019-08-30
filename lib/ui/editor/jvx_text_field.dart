import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';

class JVxTextField extends JVxEditor<String> implements IEditor<String> {
  TextEditingController _controller;

  JVxTextField(Key componentId, BuildContext context) : super(componentId, context);

  @override
  setValue(String data) {
    _controller.text = data;
  }

  @override
  String getValue() {
    return _controller.text;
  }

  @override
  Widget getWidget() {
    _controller = new TextEditingController(text: getValue());

    return TextField(
      style: this.style,
      key: componentId,
      enabled: this.enabled,
      controller: _controller,
    );
  }
}