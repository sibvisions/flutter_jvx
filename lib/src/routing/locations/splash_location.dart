import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_client/src/mask/splash/splash_widget.dart';

class SplashLocation extends BeamLocation<BeamState> {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      const BeamPage(child: SplashWidget()),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ["/splash"];
}
