import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_widget.dart';

abstract class IComponentCreator {
  BuildContext context;

  IComponentCreator([this.context]);

  ComponentWidget createComponent(ChangedComponent changedComponent);
}
