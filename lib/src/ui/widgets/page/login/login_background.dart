import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/app/get_package_string.dart';
import 'dart:io';

import '../../../../models/state/app_state.dart';
import '../../../../util/download/download_helper.dart';
import 'arc_clipper.dart';

class LoginBackground extends StatelessWidget {
  final AppState appState;
  final bool colorsInverted;

  LoginBackground(
      {Key? key, required this.appState, this.colorsInverted = false})
      : super(key: key);

  Image _getImage() {
    if (appState.applicationStyle != null &&
        appState.applicationStyle?.loginStyle?.logo != null) {
      String? file = appState
          .fileConfig.files[appState.applicationStyle!.loginStyle!.logo!];

      if (kIsWeb && file != null && file.isNotEmpty) {
        return Image.memory(
          base64Decode(file),
          fit: BoxFit.fitHeight,
        );
      } else if (!kIsWeb) {
        return Image.file(
          File(
              '${getLocalFilePath(baseUrl: appState.serverConfig!.baseUrl, appName: appState.serverConfig!.appName, appVersion: appState.applicationMetaData!.version, translation: false, baseDir: appState.baseDirectory)}${appState.applicationStyle!.loginStyle!.logo}'),
          fit: BoxFit.fitHeight,
        );
      } else {
        return Image.asset(
          getPackageString(appState, 'assets/images/logo.png'),
          fit: BoxFit.fitHeight,
        );
      }
    } else {
      return Image.asset(
        getPackageString(appState, 'assets/images/logo.png'),
        fit: BoxFit.fitHeight,
      );
    }
  }

  ImageProvider _getBackgroundImage() {
    if (kIsWeb &&
        appState.applicationStyle?.loginStyle?.icon != null &&
        appState.fileConfig
                .files[appState.applicationStyle?.loginStyle?.icon] !=
            null) {
      return MemoryImage(base64Decode(appState
          .fileConfig.files[appState.applicationStyle!.loginStyle!.icon]!));
    } else if (!kIsWeb) {
      File file = File(
          '${appState.baseDirectory}${appState.applicationStyle!.loginStyle!.icon}');

      if (file.existsSync()) {
        return FileImage(file);
      } else {
        return AssetImage(
            getPackageString(appState, 'assets/images/logo.png'));
      }
    } else {
      return AssetImage(
          getPackageString(appState, 'assets/images/logo.png'));
    }
  }

  Widget topHalf(BuildContext context) {
    return Flexible(
      flex: 2,
      child: ClipPath(
        clipper: ArcClipper(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorsInverted
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: _getImage(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomHalf(BuildContext context) => Flexible(
        flex: 3,
        child: Container(
          color: colorsInverted ? Theme.of(context).primaryColor : Colors.white,
        ),
      );

  @override
  Widget build(BuildContext context) {
    late Widget child;

    if (appState.applicationStyle != null &&
        appState.applicationStyle?.loginStyle?.icon != null) {
      child = Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: _getBackgroundImage(), fit: BoxFit.cover)),
        child: Column(
          children: [topHalf(context), bottomHalf(context)],
        ),
      );
    } else {
      child = Column(
        children: <Widget>[topHalf(context), bottomHalf(context)],
      );
    }

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height),
        child: IntrinsicHeight(child: child),
      ),
    );
  }
}
