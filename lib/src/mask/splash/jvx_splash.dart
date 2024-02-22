/*
 * Copyright 2022 SIB Visions GmbH
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import '../../../flutter_jvx.dart';
import '../../flutter_ui.dart';
import '../../service/ui/i_ui_service.dart';

class JVxSplash extends StatefulWidget {
  final bool showAppName;
  final Widget? logo;
  final Widget? branding;
  final Widget background;
  final AsyncSnapshot? snapshot;
  final bool centerBranding;

  const JVxSplash({
    super.key,
    this.snapshot,
    this.showAppName = true,
    this.logo,
    this.branding,
    this.centerBranding = false,
    required this.background,
  });

  @override
  State<JVxSplash> createState() => _JVxSplashState();
}

class _JVxSplashState extends State<JVxSplash> {
  late Stream<double> stream;

  @override
  void initState() {
    super.initState();
    stream = progress(100);
  }

  Stream<double> progress(int max) async* {
    int start = 0;
    while (mounted && (start / 66) <= max) {
      await Future.delayed(const Duration(milliseconds: 16));
      start++;
      // yield log(start) / log(max);
      yield round(atan(start / 66) / (pi / 2) * 100, decimals: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.background,
          Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Expanded(child: SizedBox.shrink()),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    if (widget.logo != null) widget.logo!,
                    if (widget.showAppName)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          FlutterUI.packageInfo.appName,
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
              if (widget.snapshot?.connectionState != ConnectionState.done && IUiService().getJVxDialogs().isEmpty)
                Container(
                  height: 15,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: StreamBuilder<double>(
                      stream: stream,
                      builder: (context, snapshot) {
                        var value = (snapshot.data ?? 0);
                        return LiquidLinearProgressIndicator(
                          value: value / 100,
                          valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                          backgroundColor: Colors.white,
                          borderRadius: 15.0,
                          borderWidth: 2.0,
                          borderColor: Theme.of(context).colorScheme.primary,
                          direction: Axis.horizontal,
                          center: Text(
                            FlutterUI.translateLocal("Starting..."),
                            style: TextStyle(
                              color: value > 60
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 9.0,
                            ),
                          ),
                        );
                      }),
                ),
              if (!widget.centerBranding) ..._createBottomBranding(),
              if (widget.centerBranding) ..._createCenteredBranding(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _createBottomBranding() {
    return [
      Expanded(
        flex: 2,
        child: widget.branding == null
            ? const SizedBox.shrink()
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, constraints) => ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: min(50, constraints.maxHeight)),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  widget.branding!,
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, constraints) => ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: min(50, constraints.maxHeight)),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ];
  }

  List<Widget> _createCenteredBranding() {
    List<Widget> widgets = [
      const Expanded(child: SizedBox.shrink()),
    ];
    if (widget.branding != null) {
      widgets.addAll([
        Align(
          alignment: Alignment.bottomCenter,
          child: widget.branding,
        ),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: min(50, constraints.maxHeight)),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ]);
    }
    return widgets;
  }
}
