import '../request.dart';
import '../so_action.dart';

class PressButton extends Request {
  SoAction action;

  PressButton(this.action, String clientId)
      : super(RequestType.PRESS_BUTTON, clientId);

  Map<String, dynamic> toJson() =>
      {'clientId': clientId, 'componentId': action.componentId};
}
