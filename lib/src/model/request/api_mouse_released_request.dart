import 'api_mouse_request.dart';

class ApiMouseReleasedRequest extends ApiMouseRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiMouseReleasedRequest({
    required super.componentName,
    super.button,
    super.clickCount,
    super.x,
    super.y,
  });
}
