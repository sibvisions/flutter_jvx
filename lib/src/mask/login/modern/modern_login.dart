/* Copyright 2022 SIB Visions GmbH
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_ui.dart';
import '../../../model/command/api/login_command.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../../service/config/config_service.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../../state/app_style.dart';
import '../login.dart';
import 'cards/change_password_card.dart';
import 'cards/lost_password_card.dart';
import 'cards/manual_card.dart';
import 'middle_clipper_with_double_curve.dart';

class ModernLogin extends StatelessWidget implements Login {
  final LoginMode mode;

  // Parameter workaround
  late bool showSettingsInCard;

  ModernLogin({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    String? loginLogo = appStyle['login.logo'];
    String? loginTitle = appStyle['login.title'];

    bool inverseColor = ParseUtil.parseBool(appStyle['login.inverseColor']) ?? false;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          showSettingsInCard = ManualCard.showSettingsInCard(constraints);
          return Stack(
            children: [
              buildBackground(context, loginLogo, topColor, bottomColor),
              if (mode == LoginMode.Manual && !showSettingsInCard)
                Positioned(
                  right: 0,
                  bottom: 35,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      backgroundColor: Theme.of(context).cardColor.withOpacity(0.9),
                      padding: kIsWeb ? const EdgeInsets.all(16.0) : const EdgeInsets.all(10.0),
                    ),
                    onPressed: () => IUiService().routeToSettings(),
                    icon: const FaIcon(FontAwesomeIcons.gear),
                    label: Text(
                      FlutterUI.translate("Settings"),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              Center(
                child: SizedBox(
                  width: min(600, MediaQuery.of(context).size.width / 10 * 8),
                  child: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: buildCard(context, mode),
                        ),
                        Center(
                          child: Material(
                            color: JVxColors.lighten(Theme.of(context).colorScheme.primary, 0.3),
                            elevation: 3,
                            borderRadius: BorderRadius.circular(32),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 28.0),
                              child: Text(
                                loginTitle ?? ConfigService().getAppName()!.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget buildBackground(BuildContext context, String? loginLogo, Color? topColor, Color? bottomColor) {
    return Container(
      decoration: BoxDecoration(
        color: topColor ?? Colors.transparent,
        gradient: topColor != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                colors: [
                  topColor,
                  JVxColors.lighten(topColor, 0.2),
                ],
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(const Size.fromWidth(650)),
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
          Expanded(
            flex: 8,
            child: ClipPath(
              clipper: MiddleClipperWithDoubleCurve(),
              child: Container(
                decoration: BoxDecoration(
                  color: bottomColor ??
                      JVxColors.adjustByBrightness(
                        Theme.of(context).brightness,
                        Theme.of(context).scaffoldBackgroundColor,
                        0.05,
                      ),
                  gradient: bottomColor != null
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          colors: [
                            bottomColor,
                            JVxColors.lighten(bottomColor, 0.2),
                          ],
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildCard(BuildContext context, LoginMode? mode) {
    Widget card;
    switch (mode) {
      case LoginMode.LostPassword:
        card = const LostPasswordCard();
        break;
      case LoginMode.ChangePassword:
      case LoginMode.ChangeOneTimePassword:
        Map<String, String?>? dataMap = context.currentBeamLocation.data as Map<String, String?>?;
        card = ChangePasswordCard(
          useOTP: mode == LoginMode.ChangeOneTimePassword,
          username: dataMap?[ApiObjectProperty.username],
          password: dataMap?[ApiObjectProperty.password],
        );
        break;
      case LoginMode.Manual:
      default:
        card = ManualCard(showSettings: showSettingsInCard);
        break;
    }
    return card;
  }
}
