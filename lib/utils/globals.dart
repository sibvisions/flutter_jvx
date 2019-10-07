library jvx_mobile_v3.globals;

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/application_style/application_style_resp.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/model/startup/startup_resp.dart';

String appName;
String baseUrl = 'http://172.16.0.19:8080/JVx.mobile/services/mobile'; //'http://172.16.0.15:8080/JVx.mobile/services/mobile';
//String baseUrl = 'http://127.0.0.1:8080/JVx.mobile/services/mobile';
String language = 'de';
String clientId;
String jsessionId;
List<String> images;
Map<String, String> translation = <String, String>{};
String dir;
ApplicationStyleResponse applicationStyle;
bool isLoading = false;
bool hasToDownload = false;
StartupResponse startupResponse;
String appVersion;
String username = '';
List<MenuItem> items;
prefix0.Action changeScreen;
