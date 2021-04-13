import '../api/response_objects/application_parameters_response_object.dart';

class ApplicationParameters {
  Map<String, dynamic> parameters = <String, dynamic>{};

  ApplicationParameters({Map<String, dynamic>? initialParameters});

  dynamic udpate(String key, dynamic value) {
    parameters[key] = value;
  }

  dynamic? get(String key) {
    return parameters[key];
  }

  dynamic updateFromResponseObject(
      ApplicationParametersResponseObject appParameters) {
    parameters.addAll(appParameters.parameters!);
  }
}
