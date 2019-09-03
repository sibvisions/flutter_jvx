library jvx_mobile_v3.globals;

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style_resp.dart';

String appName = 'demo';
String baseUrl = 'http://172.16.0.20:8080/JVx.mobile/services/mobile';
//String baseUrl = 'http://127.0.0.1:8080/JVx.mobile/services/mobile';
String language = 'de';
String clientId;
String jsessionId;
List<String> images;
Map<String, String> translation = <String, String>{};
String dir;
ApplicationStyleResponse applicationStyle;
GlobalKey openPageKey = GlobalKey();