library jvx_mobile_v3.globals;

import 'package:jvx_mobile_v3/custom_screen/custom_screen_api.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/response/application_style_resp.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';

String appName;
String baseUrl; //'http://172.16.0.15:8080/JVx.mobile/services/mobile';
String language = 'de';
bool debug = false;
String clientId;
String jsessionId;
List<String> images;
Map<String, String> translation = <String, String>{};
String dir;
ApplicationStyleResponse applicationStyle;
bool isLoading = false;
bool hasToDownload = false;
String appVersion;
String username = '';
String profileImage = '';
String password = '';
String appMode = '';
List<MenuItem> items;
prefix0.Action changeScreen;
int timeout = 10;
int uploadPicWidth = 320;
String displayName;
bool handleSessionTimeout = true;

// For Custom Screen
CustomScreenApi customScreenApi;