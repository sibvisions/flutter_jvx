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

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../flutter_ui.dart';
import '../../../model/command/api/login_command.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../../state/app_style.dart';
import '../login.dart';
import 'arc_clipper.dart';
import 'cards/change_one_time_password_card.dart';
import 'cards/change_password.dart';
import 'cards/lost_password_card.dart';
import 'cards/manual_card.dart';

class DefaultLogin extends StatelessWidget implements Login {
  final LoginMode mode;

  const DefaultLogin({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    String? loginLogo = appStyle['login.logo'];

    bool inverseColor = ParseUtil.parseBool(appStyle['login.inverseColor']) ?? false;
    bool colorGradient = ParseUtil.parseBool(appStyle['login.colorGradient']) ?? true;

    Color? topColor = ParseUtil.parseHexColor(appStyle['login.topColor']) ??
        ParseUtil.parseHexColor(appStyle['login.background']) ??
        Theme.of(context).colorScheme.primary;
    Color? bottomColor = ParseUtil.parseHexColor(appStyle['login.bottomColor']);

    if (inverseColor) {
      var tempTop = topColor;
      topColor = bottomColor;
      bottomColor = tempTop;
    }

    return Scaffold(
      backgroundColor: bottomColor ?? JVxColors.lighten(Theme.of(context).scaffoldBackgroundColor, 0.05),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          buildBackground(context, loginLogo, topColor, bottomColor, colorGradient),
          Center(
            child: SizedBox(
              width: min(600, MediaQuery.of(context).size.width / 10 * 8),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SingleChildScrollView(
                  // Is there to allow scrolling the login if there is not enough space.
                  // E.g.: Holding a phone horizontally and trying to login needs scrolling to be possible.
                  child: Card(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: buildCard(context, mode),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildBackground(
    BuildContext context,
    String? loginLogo,
    Color? topColor,
    Color? bottomColor,
    bool colorGradient,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 4,
          child: ClipPath(
            clipper: ArcClipper(),
            child: Container(
              decoration: BoxDecoration(
                color: topColor ?? Colors.transparent,
                gradient: colorGradient && topColor != null
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        colors: [
                          topColor,
                          JVxColors.lighten(topColor, 0.2),
                        ],
                        end: Alignment.bottomCenter,
                      )
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size.fromWidth(650)),
                  child: loginLogo != null
                      ? ImageLoader.loadImage(
                          loginLogo,
                          imageProvider: ImageLoader.getImageProvider(loginLogo),
                          pFit: BoxFit.scaleDown,
                        )
                      : Image.asset(
                          ImageLoader.getAssetPath(
                            FlutterUI.package,
                            "assets/images/branding_sib_visions.png",
                          ),
                          fit: BoxFit.scaleDown,
                        ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: ColoredBox(
            color: bottomColor ?? Colors.transparent,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildCard(BuildContext context, LoginMode? mode) {
    Widget card;
    switch (mode) {
      case LoginMode.LostPassword:
        card = LostPasswordCard();
        break;
      case LoginMode.ChangePassword:
        Map<String, String?>? dataMap = context.currentBeamLocation.data as Map<String, String?>?;
        card = ChangePassword(
          username: dataMap?[ApiObjectProperty.username],
          password: dataMap?[ApiObjectProperty.password],
        );
        break;
      case LoginMode.ChangeOneTimePassword:
        card = ChangeOneTimePasswordCard();
        break;
      case LoginMode.Manual:
      default:
        card = const ManualCard();
        break;
    }
    return card;
  }
}
