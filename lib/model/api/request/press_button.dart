import '../../so_action.dart';
import '../../../model/api/request/request.dart';
import '../../../utils/globals.dart' as globals;

/// Model for the [PressButton] request.
class PressButton extends Request {
  SoAction action;

  PressButton(this.action)
      : super(
            clientId: globals.clientId, requestType: RequestType.PRESS_BUTTON);

  Map<String, dynamic> toJson() =>
      {'clientId': clientId, 'componentId': action.componentId};
}
