import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';

class OfflineStartupPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;

  const OfflineStartupPageWidget(
      {Key? key, required this.appState, required this.manager})
      : super(key: key);

  @override
  _OfflineStartupPageWidgetState createState() =>
      _OfflineStartupPageWidgetState();
}

class _OfflineStartupPageWidgetState extends State<OfflineStartupPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
