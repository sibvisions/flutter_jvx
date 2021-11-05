import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_application_parameters.dart';
import 'package:flutter_jvx/src/models/events/meta/authentication_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/meta/on_authentication_event.dart';
import 'package:flutter_jvx/src/util/mixin/service/config_app_service_mixin.dart';

class ApplicationParameterProcessor with OnAuthenticationEvent, ConfigAppServiceMixin implements IProcessor {

  @override
  void processResponse(json) {
    ResponseApplicationParameters applicationParameters = ResponseApplicationParameters.fromJson(json);

    String? isAuthenticated = applicationParameters.authenticated;
    if(isAuthenticated != null) {
      if(isAuthenticated == "yes"){
        configAppService.authenticated = true;
        var event = AuthenticationEvent(
            authenticationStatus: true,
            origin: this,
            reason: "Authentication set to $isAuthenticated in ApplicationParameters"
        );
        fireAuthenticationEvent(event);
      }
    }
  }

}