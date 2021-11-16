import 'package:flutter_jvx/src/models/api/action/processor_action.dart';

class MetaAction extends ProcessorAction {

  ///Client id of the current Session
  final String clientId;

  MetaAction({required this.clientId});
}