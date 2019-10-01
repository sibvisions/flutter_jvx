import 'package:jvx_mobile_v3/model/base_resp.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';

/// Model for the [PressButton] Response.
/// 
/// [updateComponents]: A list of [ChangedComponent]'s which will be updated or added to the [JVxScreen].
class PressButtonResponse extends BaseResponse {
  List<ChangedComponent> updatedComponents;

  PressButtonResponse({this.updatedComponents, String name}) {
    super.name = name;
  }

  PressButtonResponse.fromJson(List<dynamic> json) : super.fromJson(json) {
    if (isError || isSessionExpired)
      return;
    
    updatedComponents = List();
    name = json[1]['name'];
    List<dynamic> chComp = json[0]['changedComponents'];

    chComp?.forEach((val) {
      updatedComponents.add(ChangedComponent.fromJson(val));
    });
  }   
}