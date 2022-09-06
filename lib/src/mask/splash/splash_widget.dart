import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'loading_widget.dart';

class SplashWidget extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Widget Function(BuildContext context)? loadingBuilder;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const SplashWidget({
    Key? key,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loadingBuilder?.call(context) ?? const LoadingWidget();
  }
}
