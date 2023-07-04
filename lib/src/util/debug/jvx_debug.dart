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
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

import '../../flutter_ui.dart';
import '../../mask/jvx_overlay.dart';
import '../../mask/login/login_page.dart';
import '../../model/command/api/login_command.dart';
import '../../routing/locations/main_location.dart';
import '../../service/api/i_api_service.dart';
import '../../service/api/shared/repository/online_api_repository.dart';
import '../../service/apps/i_app_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../widgets/progress/progress_dialog_widget.dart';
import '../widgets/status_banner.dart';

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
              onPressed: () => IAppService().startApp(),
              child: const Text("Restart"),
            ),
          ),
          ListTile(
            title: Text(
              "Theme",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () => FlutterUI.maybeOf(FlutterUI.getEffectiveContext())?.changedTheme(),
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
              "Delete Cookies",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () {
                IApiService().getRepository().setCookies({});
              },
              child: const Text("Delete"),
            ),
          ),
          ListTile(
            title: Text(
              "API Service",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ControlButtons(
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
              labels: const [
                "Start",
                "Stop",
              ],
            ),
          ),
          ListTile(
            title: Text(
              "Web Socket",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ControlButtons(
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
              labels: const [
                "Start",
                "Stop",
              ],
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
          ListTile(
            title: Text(
              "Navigator",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ControlButtons(
              hPadding: 14,
              onPressed: (index) async {
                var effectiveContext = FlutterUI.getEffectiveContext();
                NavigatorState? navigator;
                if (effectiveContext != null) {
                  navigator = Navigator.maybeOf(effectiveContext);
                }
                switch (index) {
                  case 0:
                    await navigator?.maybePop();
                    break;
                  case 1:
                    navigator?.pop();
                    break;
                }
              },
              labels: const [
                "Maybe",
                "Pop",
              ],
            ),
          ),
          ListTile(
            title: Text(
              "Beamer",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: () => FlutterUI.getBeamerDelegate().beamBack(),
              child: const Text("Back"),
            ),
          ),
          ListTile(
            title: Text(
              "Internal URL",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ControlButtons(
              hPadding: 14,
              onPressed: (index) async {
                switch (index) {
                  case 0:
                    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.showInternalUrl = true;
                    break;
                  case 1:
                    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.showInternalUrl = false;
                    break;
                }
              },
              labels: const [
                "Show",
                "Hide",
              ],
            ),
          ),
          ListTile(
            title: Text(
              "Loading",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ControlButtons(
              onPressed: (index) async {
                switch (index) {
                  case 0:
                    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.showLoading(Duration.zero);
                    break;
                  case 1:
                    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.hideLoading();
                    break;
                }
              },
              labels: const [
                "On",
                "Off",
              ],
            ),
          ),
          ListTile(
            title: Text(
              "Connection State",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ControlButtons(
              hPadding: 18,
              onPressed: (index) async {
                switch (index) {
                  case 0:
                    JVxOverlay.maybeOf(FlutterUI.getEffectiveContext())?.setConnectionState(true);
                    break;
                  case 1:
                    JVxOverlay.maybeOf(FlutterUI.getEffectiveContext())?.setConnectionState(false);
                    break;
                  case 2:
                    JVxOverlay.maybeOf(FlutterUI.getEffectiveContext())?.resetConnectionState();
                    break;
                }
              },
              labels: const [
                "On",
                "Off",
                "Reset",
              ],
            ),
          ),
          if (kDebugMode)
            ListTile(
              title: Text(
                "Debugger",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: OutlinedButton(
                onPressed: () {
                  debugger(message: "Manually triggered break point.");
                },
                child: const Text("Trigger"),
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
                  key.currentState!.update(Config(
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
            trailing: ControlButtons(
              hPadding: 18,
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
              labels: const [
                "Top",
                "Bottom",
              ],
            ),
          ),
          StatefulBuilder(builder: (context, setState) {
            return DropdownButton<LoginMode>(
              hint: const Text("Route to Login"),
              value: cast<MainLocation>(FlutterUI.getBeamerDelegate().currentBeamLocation)?.loginModeNotifier.value,
              items: LoginMode.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      ))
                  .toList(),
              onChanged: (LoginMode? value) {
                LoginPage.changeMode(mode: value!);
                setState(() {});
              },
              isExpanded: true,
            );
          }),
        ],
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final List<String> labels;
  final void Function(int index) onPressed;
  final double maxHeight;
  final double hPadding;

  const ControlButtons({
    super.key,
    required this.labels,
    required this.onPressed,
    this.maxHeight = 44,
    this.hPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ToggleButtons(
        onPressed: onPressed,
        isSelected: [
          for (String _ in labels) false,
        ],
        borderRadius: BorderRadius.circular(20),
        children: [
          for (String label in labels)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: Text(label),
            ),
        ],
      ),
    );
  }
}
