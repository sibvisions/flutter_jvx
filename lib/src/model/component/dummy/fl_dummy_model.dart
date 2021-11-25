import 'package:flutter_client/src/model/component/fl_component_model.dart';

class FlDummyModel extends FlComponentModel {

  FlDummyModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  FlDummyModel.updateProperties(FlComponentModel oldModel, dynamic json) :
      super.updatedProperties(oldModel, json);

  @override
  FlComponentModel updateComponent(FlComponentModel oldModel, dynamic json) {
    return FlDummyModel.updateProperties(oldModel, json);
  }
}