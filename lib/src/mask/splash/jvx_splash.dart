import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';

class JVxSplash extends StatefulWidget {
  final bool showAppName;
  final Image? logo;
  final Image? branding;
  final ImageProvider background;
  final AsyncSnapshot? snapshot;

  const JVxSplash({
    Key? key,
    this.snapshot,
    this.showAppName = true,
    this.logo,
    this.branding,
    required this.background,
  }) : super(key: key);

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
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: widget.background,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    if (widget.logo != null) widget.logo!,
                    if (widget.showAppName)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          FlutterJVx.packageInfo.appName,
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
            if (widget.snapshot?.connectionState != ConnectionState.done && UiService().getFrames().isEmpty)
              Container(
                height: 15,
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: StreamBuilder<double>(
                    stream: stream,
                    builder: (context, snapshot) {
                      return LiquidLinearProgressIndicator(
                        value: (snapshot.data ?? 0) / 100,
                        valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                        backgroundColor: Colors.white,
                        borderRadius: 15.0,
                        borderWidth: 2.0,
                        borderColor: Theme.of(context).colorScheme.primary,
                        direction: Axis.horizontal,
                        center: Text(
                          "Starting...",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 9.0,
                          ),
                        ),
                      );
                    }),
              ),
            const Expanded(child: SizedBox.shrink()),
            if (widget.branding != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: widget.branding,
                ),
              ),
          ],
        ),
      ],
    ));
  }
}
