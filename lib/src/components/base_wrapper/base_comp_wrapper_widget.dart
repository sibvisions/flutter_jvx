import 'package:flutter/cupertino.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/component/fl_component_model.dart';

abstract class BaseCompWrapperWidget<T extends FlComponentModel> extends StatefulWidget with UiServiceGetterMixin {
  BaseCompWrapperWidget({Key? key, required this.id}) : super(key: key);

  final String id;

  T get model => getUiService().getComponentModel(pComponentId: id)! as T;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return ("$id $key");
  }
}
