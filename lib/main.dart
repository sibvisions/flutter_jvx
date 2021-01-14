import 'package:flutter/material.dart';
import 'application_widget.dart';
import 'injection_container.dart' as di;

void main() async {
  // Nedded for the dependency injection from GetIt
  WidgetsFlutterBinding.ensureInitialized();
  // Intializing all needed dependencies
  await di.init();
  // Running the app
  runApp(ApplicationWidget());
}
