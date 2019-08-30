import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';

abstract class JVxEditor<T> extends JVxComponent implements IEditor<T> {
  JVxEditor(Key componentId, BuildContext context) : super(componentId, context);
}