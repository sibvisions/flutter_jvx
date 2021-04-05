import 'dart:io';

import 'package:flutter/material.dart';

import 'application_widget.dart';
import 'core/services/remote/rest/cert_http_overrides.dart';
import 'injection_container.dart' as di;

void main() async {
  // Overriding http client to allow certificates from visionx
  HttpOverrides.global = CertHttpOverrides();

  // Needed for the dependency injection from GetIt
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing all needed dependenecies
  await di.init();
  // Running the app
  runApp(ApplicationWidget());
}
