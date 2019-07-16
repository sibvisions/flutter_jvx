import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/di/dependency_injection.dart';
import 'package:jvx_mobile_v3/jvx_mobile.dart';

void main() {
  Injector.configure(Flavor.PRO);
  runApp(JvxMobile());
}