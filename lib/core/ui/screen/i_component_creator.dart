import 'package:flutter/material.dart';

import '../component/component_model.dart';
import '../component/component_widget.dart';

abstract class IComponentCreator {
  BuildContext context;

  IComponentCreator([this.context]);

  ComponentWidget createComponent(ComponentModel componentModel);
}
