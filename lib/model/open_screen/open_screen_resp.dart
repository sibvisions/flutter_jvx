import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/base_resp.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';

/// Model for the Response of the [OpenScreen] Request.
/// 
/// * [changedComponents]: A list of items which will be build and shown in the [OpenScreenPage].
/// * [metaData]: Information about the [data] and how to use it.
/// * [data]: Data which will be filled into the [JVxComponents] generated with the [changedComponents].
class OpenScreenResponse extends BaseResponse {
  String title = "";
  List<ChangedComponent> changedComponents;
  List<JVxMetaData> metaData;
  List<JVxData> data;
  String componentId;

  OpenScreenResponse(
      {@required this.changedComponents,
      @required this.componentId,
      @required String name}) {
    super.name = name;
  }

  OpenScreenResponse.fromJson(List json) : super.fromJson(json) {
    if (isError || isSessionExpired) return;

    changedComponents = <ChangedComponent>[];
    componentId = json[0]['componentId'];

    List<dynamic> chComp = json[0]['changedComponents'];

    if (chComp != null) {
      chComp.forEach((val) {
        changedComponents.add(ChangedComponent.fromJson(val));
      });
    }

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
