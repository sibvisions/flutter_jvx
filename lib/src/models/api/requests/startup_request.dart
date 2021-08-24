import '../request.dart';

class StartupRequest extends Request {
  final String appName;
  final String url;
  final int screenWidth;
  final int screenHeight;
  final String appMode;
  final int readAheadLimit;
  final String deviceId;
  final String? authKey;
  final String? username;
  final String? password;
  final String? technology;
  final String? osName;
  final String? osVersion;
  final String? appVersion;
  final String? deviceType;
  final String? deviceTypeModel;
  final String? deviceMode;
  final String language;
  final bool? forceNewSession;
  final Map<String, dynamic> parameter;

  @override
  String get debugInfo => 'url: $url, appName: $appName, language: $language';

  StartupRequest(
      {required String clientId,
      required this.url,
      required this.appName,
      required this.screenWidth,
      required this.screenHeight,
      required this.appMode,
      required this.readAheadLimit,
      required this.deviceId,
      required this.language,
      this.authKey,
      this.username,
      this.password,
      this.technology,
      this.osName,
      this.osVersion,
      this.appVersion,
      this.deviceType,
      this.deviceTypeModel,
      this.deviceMode,
      this.forceNewSession,
      this.parameter = const <String, dynamic>{}})
      : super(clientId: clientId);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'applicationName': appName,
        'authKey': authKey,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'appMode': appMode,
        'readAheadLimit': readAheadLimit,
        'deviceId': deviceId,
        'userName': username,
        'password': password,
        'url': url,
        'technology': technology,
        'osName': osName,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'deviceType': deviceType,
        'deviceTypeModel': deviceTypeModel,
        'deviceMode': this.deviceMode,
        'langCode': this.language,
        'forceNewSession': this.forceNewSession,
        ...parameter.map((key, value) => MapEntry('custom_$key', value))
      };
}
