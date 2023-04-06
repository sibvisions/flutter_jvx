/*
 * Copyright 2023 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

import '../../flutter_ui.dart';
import '../../mask/jvx_overlay.dart';
import '../../model/command/api/login_command.dart';
import '../../routing/locations/login_location.dart';
import '../../service/api/i_api_service.dart';
import '../../service/api/shared/repository/online_api_repository.dart';
import '../../service/ui/i_ui_service.dart';
import '../misc/status_banner.dart';
import '../progress/progress_dialog_widget.dart';

class JVxDebug extends StatelessWidget {
  const JVxDebug({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugEntry(
      title: const Text("Flutter JVx"),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "FlutterUI",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () =>
                  FlutterUI.maybeOf(FlutterUI.getCurrentContext() ?? FlutterUI.getSplashContext())?.startApp(),
              child: const Text("Restart"),
            ),
          ),
          ListTile(
            title: Text(
              "Theme",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () =>
                  FlutterUI.maybeOf(FlutterUI.getCurrentContext() ?? FlutterUI.getSplashContext())?.changedTheme(),
              child: const Text("Reload"),
            ),
          ),
          ListTile(
            title: Text(
              "Client ID",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () {
                // Random invalid client id
                IUiService().updateClientId("2b63e617-d407-4b40-81b1-ef034233e26a");
              },
              child: const Text("Invalidate"),
            ),
          ),
          ListTile(
            title: Text(
              "API Service",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 44),
              child: ToggleButtons(
                onPressed: (index) async {
                  switch (index) {
                    case 0:
                      await IApiService().getRepository().start();
                      break;
                    case 1:
                      await IApiService().getRepository().stop();
                      break;
                  }
                },
                isSelected: const [
                  false,
                  false,
                ],
                borderRadius: BorderRadius.circular(20),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Start"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Stop"),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Web Socket",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 44),
              child: ToggleButtons(
                onPressed: (index) async {
                  switch (index) {
                    case 0:
                      await (IApiService().getRepository() as OnlineApiRepository?)?.startWebSocket();
                      break;
                    case 1:
                      await (IApiService().getRepository() as OnlineApiRepository?)?.stopWebSocket();
                      break;
                  }
                },
                isSelected: const [
                  false,
                  false,
                ],
                borderRadius: BorderRadius.circular(20),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Start"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Stop"),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Web Socket",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () async {
                cast<OnlineApiRepository>(IApiService().getRepository())?.jvxWebSocket?.reconnectWebSocket();
              },
              child: const Text("Reconnect"),
            ),
          ),
          StatefulBuilder(builder: (context, setState) {
            return DropdownButton<LoginMode>(
              hint: const Text("Route to Login"),
              value: cast<LoginLocation>(FlutterUI.getBeamerDelegate().currentBeamLocation)?.modeNotifier.value,
              items: LoginMode.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      ))
                  .toList(),
              onChanged: (LoginMode? value) {
                IUiService().routeToLogin(mode: value!);
                setState(() {});
              },
              isExpanded: true,
            );
          }),
          ListTile(
            title: Text(
              "Connection Banner",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 44),
              child: ToggleButtons(
                onPressed: (index) async {
                  switch (index) {
                    case 0:
                      JVxOverlay.maybeOf(FlutterUI.getCurrentContext() ?? FlutterUI.getSplashContext())
                          ?.setConnectionState(true);
                      break;
                    case 1:
                      JVxOverlay.maybeOf(FlutterUI.getCurrentContext() ?? FlutterUI.getSplashContext())
                          ?.setConnectionState(false);
                      break;
                  }
                },
                isSelected: const [
                  false,
                  false,
                ],
                borderRadius: BorderRadius.circular(20),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("On"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Off"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UIDebug extends StatelessWidget {
  const UIDebug({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugEntry(
      title: const Text("UI"),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Progress Dialog",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () async {
                var key = GlobalKey<ProgressDialogState>();
                unawaited(showDialog(
                  context: context,
                  builder: (context) => ProgressDialogWidget(
                      key: key,
                      config: Config(
                        progress: 0,
                        maxProgress: 100,
                        message: "Loading...",
                        barrierDismissible: true,
                      )),
                ));
                await Future.delayed(const Duration(seconds: 2));

                for (int i = 0; i <= 100; i++) {
                  key.currentState!.update(
                      config: Config(
                    progress: i,
                  ));
                  await Future.delayed(const Duration(milliseconds: 50));
                }
              },
              child: const Text("Test"),
            ),
          ),
          ListTile(
            title: Text(
              "Banner",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 44),
              child: ToggleButtons(
                onPressed: (index) async {
                  late StatusBannerLocation location;
                  late String message;
                  switch (index) {
                    case 0:
                      location = StatusBannerLocation.top;
                      message = "Top Banner";
                      break;
                    case 1:
                      location = StatusBannerLocation.bottom;
                      message = "Bottom Banner";
                      break;
                  }

                  OverlayEntry? entry;
                  entry = OverlayEntry(
                    builder: (context) {
                      return StatusBanner(
                        translationCurve: Curves.fastOutSlowIn,
                        location: location,
                        onClose: () => entry?.remove(),
                        child: Text(FlutterUI.translate(message)),
                      );
                    },
                  );
                  Overlay.of(context).insert(entry);
                },
                isSelected: const [
                  false,
                  false,
                ],
                borderRadius: BorderRadius.circular(20),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Top"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Bottom"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
