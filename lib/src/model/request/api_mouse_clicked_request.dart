import 'api_mouse_request.dart';

class ApiMouseClickedRequest extends ApiMouseRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiMouseClickedRequest({
    required super.componentName,
    super.button,
    super.clickCount,
    super.x,
    super.y,
  });
}
