import 'package:flutter/material.dart';
import 'application_widget.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(ApplicationWidget());
}
