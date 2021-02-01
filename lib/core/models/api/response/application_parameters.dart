import '../response_object.dart';

class ApplicationParameters extends ResponseObject {
  Map<String, dynamic> parameters;

  dynamic getParameter(String key) =>
      parameters != null && parameters.length > 0 ? parameters[key] : null;

  void updateParameters(ApplicationParameters applicationParameters) {
    if (applicationParameters != null &&
        applicationParameters.parameters != null &&
        applicationParameters.parameters.length > 0) {
      applicationParameters.parameters.forEach((key, value) {
        if (value != null) {
          this.parameters[key] = value;
        } else {
          this.parameters.remove(key);
        }
      });
    }
  }

  ApplicationParameters.fromJson(Map<String, dynamic> json)
      : parameters = json
            .map((key, value) => key != 'name' ? MapEntry(key, value) : null),
        super.fromJson(json);
}
