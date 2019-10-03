import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'component/i_component.dart';

abstract class IComponentCreator {
  BuildContext context;

  IComponentCreator([this.context]);
  IComponent createComponent(ChangedComponent component);
}