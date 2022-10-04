import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'jvx_splash.dart';

class Splash extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Widget Function(BuildContext context)? loadingBuilder;
  final AsyncSnapshot? snapshot;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const Splash({
    Key? key,
    this.loadingBuilder,
    this.snapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loadingBuilder?.call(context) ?? JVxSplash(snapshot: snapshot);
  }
}
