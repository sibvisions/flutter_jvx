import 'package:flutter/cupertino.dart';

import '../../model/component/fl_component_model.dart';

abstract class BaseCompWrapperWidget<T extends FlComponentModel> extends StatefulWidget {
  const BaseCompWrapperWidget({Key? key, required this.model}) : super(key: key);

  final T model;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return ("${model.id} $key");
  }
}
