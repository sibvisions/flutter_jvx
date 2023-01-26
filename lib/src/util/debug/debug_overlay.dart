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

import 'package:flutter/material.dart';

import 'jvx_debug.dart';

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
                style: Theme.of(context).textTheme.titleLarge!,
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
