import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';

class OpenScreenResponse {
  List<ChangedComponent> changedComponents;
  List<JVxMetaData> metaData;
  List<JVxData> data;
  String name;
  String componentId;

  OpenScreenResponse({@required this.changedComponents, @required this.componentId, @required this.name});

  OpenScreenResponse.fromJson(List json) {
    if (json[0]['title'] == 'Error')
      return;
      
    changedComponents = <ChangedComponent>[];
    name = json[0]['name'];
    componentId = json[0]['componentId'];

    List<dynamic> chComp = json[0]['changedComponents'];

    chComp.forEach((val) {
      changedComponents.add(ChangedComponent.fromJson(val));
    });

    data = <JVxData>[];
    metaData = <JVxMetaData>[];

    json.forEach((f) {
      if (f['name'] == 'dal.fetch')
        data.add(JVxData.fromJson(f));
      else if (f['name'] == 'dal.metaData')
        metaData.add(JVxMetaData.fromJson(f));
    });
  }
  
}