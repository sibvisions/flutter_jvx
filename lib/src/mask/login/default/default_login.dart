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
import 'cards/mfa/mfa_text_card.dart';
import 'cards/mfa/mfa_url_card.dart';
import 'cards/mfa/mfa_wait_card.dart';

class DefaultLogin extends StatelessWidget implements Login {
  final LoginMode mode;

  const DefaultLogin({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context).applicationStyle;
    String? loginLogo = appStyle?['login.logo'];

    bool inverseColor = ParseUtil.parseBool(appStyle?['login.inverseColor']) ?? false;
    bool colorGradient = ParseUtil.parseBool(appStyle?['login.colorGradient']) ?? true;

    Color? topColor = ParseUtil.parseHexColor(appStyle?['login.topColor']) ??
        ParseUtil.parseHexColor(appStyle?['login.background']) ??
        Theme.of(context).colorScheme.primary;
    Color? bottomColor = ParseUtil.parseHexColor(appStyle?['login.bottomColor']);

    if (inverseColor) {
      var tempTop = topColor;
      topColor = bottomColor;
      bottomColor = tempTop;
    }

    return Scaffold(
      backgroundColor: bottomColor ?? JVxColors.lighten(Theme.of(context).colorScheme.background, 0.05),
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
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
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

  /// Returns an error widget depending on the [LoginViewResponse.errorMessage].
  static Widget buildErrorMessage(BuildContext context, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Flexible(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildCard(BuildContext context, LoginMode? mode) {
    Map<String, dynamic>? dataMap = context.currentBeamLocation.data as Map<String, dynamic>?;
    Widget card;
    switch (mode) {
      case LoginMode.LostPassword:
        card = LostPasswordCard(
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
      case LoginMode.ChangePassword:
        card = ChangePassword(
          username: dataMap?[ApiObjectProperty.username],
          password: dataMap?[ApiObjectProperty.password],
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
      case LoginMode.ChangeOneTimePassword:
        card = ChangeOneTimePasswordCard(
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
      case LoginMode.MFTextInput:
        // Is repeatedly called (password is missing on repeated calls)
        card = MFATextCard(
          username: dataMap?[ApiObjectProperty.username],
          password: dataMap?[ApiObjectProperty.password],
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
      case LoginMode.MFWait:
        // Is repeatedly called
        Map<String, dynamic>? dataMap = context.currentBeamLocation.data as Map<String, dynamic>?;
        card = MFAWaitCard(
          timeout: dataMap?[ApiObjectProperty.timeout],
          timeoutReset: dataMap?[ApiObjectProperty.timeoutReset],
          confirmationCode: dataMap?[ApiObjectProperty.confirmationCode],
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
      case LoginMode.MFURL:
        // Is repeatedly called
        card = MFAUrlCard(
          timeout: dataMap?[ApiObjectProperty.timeout],
          timeoutReset: dataMap?[ApiObjectProperty.timeoutReset],
          link: dataMap?[ApiObjectProperty.link],
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
      case LoginMode.Manual:
      default:
        card = ManualCard(
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
    }
    return card;
  }
}
