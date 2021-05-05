import 'package:flutter/material.dart';

import '../../../models/state/app_state.dart';
import '../../util/inherited_widgets/app_state_provider.dart';

showLoadingIndicator(BuildContext context) {
  AppState appState = AppStateProvider.of(context)!.appState;

  if (!appState.showsLoading) {
    appState.showsLoading = true;

    showDialog(
        routeSettings: RouteSettings(name: '/loading'),
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [CircularProgressIndicator.adaptive()],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

hideLoading(BuildContext context) {
  AppState appState = AppStateProvider.of(context)!.appState;

  if (appState.showsLoading) {
    appState.showsLoading = false;
    Navigator.of(context).pop();
  }
}
