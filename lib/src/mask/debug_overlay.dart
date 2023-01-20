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

import '../flutter_ui.dart';
import '../service/api/i_api_service.dart';
import '../service/api/shared/repository/online_api_repository.dart';
import '../service/config/config_controller.dart';
import '../util/progress/progress_dialog_widget.dart';

class DebugOverlay extends StatelessWidget {
  final List<Widget> debugEntries;
  final bool useDialog;

  const DebugOverlay({
    super.key,
    this.debugEntries = const [
      JVxDebug(),
    ],
    this.useDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.separated(
      itemBuilder: (context, index) => debugEntries[index],
      separatorBuilder: (context, index) => const Divider(),
      itemCount: debugEntries.length,
    );

    Widget body;
    if (useDialog) {
      body = Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 24.0),
        backgroundColor: Theme.of(context).dialogBackgroundColor.withOpacity(0.9),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.headlineSmall!,
                    textAlign: TextAlign.start,
                    child: const Text("Debug"),
                  ),
                ),
              ),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.headline6!,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: debugEntries.length > 1 ? 600 : 300),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      body = Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Debug"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: content,
        ),
      );
    }

    return Opacity(
      opacity: 0.9,
      child: body,
    );
  }
}

class DebugEntry extends StatelessWidget {
  final Widget title;
  final Widget child;

  const DebugEntry({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.titleLarge!,
            child: title,
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ],
    );
  }
}

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
                  FlutterUI.maybeOf(FlutterUI.getCurrentContext() ?? FlutterUI.getSplashContext())?.restart(),
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
                ConfigController().updateClientId("2b63e617-d407-4b40-81b1-ef034233e26a");
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
                      await IApiService().getRepository()?.start();
                      break;
                    case 1:
                      await IApiService().getRepository()?.stop();
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
        ],
      ),
    );
  }
}
