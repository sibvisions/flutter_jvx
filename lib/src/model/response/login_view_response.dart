import 'package:collection/collection.dart';

import '../../service/api/shared/api_object_property.dart';
import '../command/api/login_command.dart';
import 'api_response.dart';

/// Response to indicate to display the login screen
class LoginViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final LoginMode? mode;

  final String? username;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginViewResponse({
    required this.mode,
    required this.username,
    required super.name,
  });

  LoginViewResponse.fromJson(super.json)
      : mode = LoginMode.values
            .firstWhereOrNull((e) => e.name.toLowerCase() == json[ApiObjectProperty.mode].toLowerCase()),
        username = json[ApiObjectProperty.username],
        super.fromJson();
}
