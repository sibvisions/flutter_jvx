import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/core/models/api/component/changed_component.dart';
import 'package:jvx_flutterclient/core/ui/component/models/component_model.dart';

class MapComponentModel extends ComponentModel {
  MapComponentModel(ChangedComponent changedComponent) : super(changedComponent); 

  @override
  void updateProperties(BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);
  }
}