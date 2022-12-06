import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';
import '../../service/storage/i_storage_service.dart';

/// The base class for all of FlutterJVx's component wrapper.
///
/// A wrapper is a stateful widget that wraps FlutterJVx widgets and handles all JVx specific implementations and functionality.
/// e.g:
///
/// Model inits/updates; Layout inits/updates; Size calculation; Subscription handling for data widgets.
abstract class BaseCompWrapperWidget<M extends FlComponentModel> extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The id of the component.
  final String id;

  /// The model of the component.
  M get model => IStorageService().getComponentModel(pComponentId: id)! as M;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const BaseCompWrapperWidget({super.key, required this.id});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return ("$id $key");
  }
}
