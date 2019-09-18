import '../base_resp.dart';
import '../changed_component.dart';

class SetValueResponse extends BaseResponse {
  List<ChangedComponent> changedComponents;

  SetValueResponse({this.changedComponents});

  SetValueResponse.fromJson(List<dynamic> json) {
    if (isError || isSessionExpired)
      return;

    changedComponents = <ChangedComponent>[];

    json.forEach((c) {
      changedComponents.add(ChangedComponent.fromJson(c));
    });
  }
}