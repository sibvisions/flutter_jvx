import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/injection_container.dart' as di;

customRunApp(Widget widgetToRun) {
  WidgetsFlutterBinding.ensureInitialized();
  di.init();
  runApp(widgetToRun);
}