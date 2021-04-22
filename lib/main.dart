import 'dart:io';

import 'package:flutter/material.dart';

import 'injection_container.dart' as di;
import 'src/runnable_widget.dart';
import 'src/services/remote/rest/cert_http_overrides.dart';

void main() async {
  // Overwriting http certificate handling
  HttpOverrides.global = CertHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  // Initializing dependencies
  await di.init();

  // Running the application
  runApp(RunnableWidget());
}
