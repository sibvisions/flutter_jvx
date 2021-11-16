import 'package:flutter_jvx/src/models/api/action/processor_action.dart';

abstract class IProcessor {
  List<ProcessorAction> processResponse(dynamic json);
}