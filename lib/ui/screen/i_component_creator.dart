import 'package:flutter/widgets.dart';
import '../../model/changed_component.dart';
import '../component/i_component.dart';

abstract class IComponentCreator {
  BuildContext context;

  IComponentCreator([this.context]);
  IComponent createComponent(ChangedComponent component);
}