import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/jvx_mobile.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';
import 'package:jvx_mobile_v3/ui/tools/restart.dart';

GetIt getIt = GetIt.instance;

void main() {
  getIt.allowReassignment = true;
  getIt.registerSingleton<JVxScreen>(JVxScreen());
  Injector.configure(Flavor.PRO);
  runApp(new RestartWidget(
    child: JvxMobile(),
  ));
}