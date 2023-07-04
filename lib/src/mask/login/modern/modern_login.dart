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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_ui.dart';
import '../../../model/command/api/login_command.dart';
import '../../../model/response/login_view_response.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../../service/apps/i_app_service.dart';
import '../../../service/config/i_config_service.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../../apps/app_overview_page.dart';
import '../../state/app_style.dart';
import '../login.dart';
import 'cards/change_password_card.dart';
import 'cards/lost_password_card.dart';
import 'cards/manual_card.dart';
import 'cards/mfa/mfa_text_card.dart';
import 'cards/mfa/mfa_url_card.dart';
import 'cards/mfa/mfa_wait_card.dart';
import 'middle_clipper_with_double_curve.dart';

class ModernLogin extends StatelessWidget implements Login {
  final LoginMode mode;

  // Parameter workaround
  final ValueNotifier<bool> showSettingsInCard = ValueNotifier(false);

  ModernLogin({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context).applicationStyle;
    String? loginLogo = appStyle?['login.logo'];
    String? loginTitle = appStyle?['login.title'];

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

    bool replaceSettingsWithApps = IAppService().showAppsButton();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          showSettingsInCard.value = ManualCard.showSettingsInCard(constraints);
          return Stack(
            children: [
              buildBackground(context, loginLogo, topColor, bottomColor, colorGradient),
              if (mode == LoginMode.Manual && !showSettingsInCard.value)
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
                      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      padding: kIsWeb ? const EdgeInsets.all(16.0) : const EdgeInsets.all(10.0),
                    ),
                    onPressed: () =>
                        replaceSettingsWithApps ? IUiService().routeToAppOverview() : IUiService().routeToSettings(),
                    icon: replaceSettingsWithApps
                        ? const Icon(AppOverviewPage.appsIcon)
                        : const FaIcon(FontAwesomeIcons.gear),
                    label: Text(
                      FlutterUI.translate(replaceSettingsWithApps ? "Apps" : "Settings"),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              Center(
                child: SizedBox(
                  width: min(600, MediaQuery.sizeOf(context).width / 10 * 8),
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
                                loginTitle ?? IConfigService().appName.value?.toUpperCase() ?? "",
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
  Widget buildBackground(
    BuildContext context,
    String? loginLogo,
    Color? topColor,
    Color? bottomColor,
    bool colorGradient,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: topColor ?? Colors.transparent,
        gradient: colorGradient && topColor != null
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
                        Theme.of(context).colorScheme.background,
                        0.05,
                      ),
                  gradient: colorGradient && bottomColor != null
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

  /// Returns an error widget depending on the [LoginViewResponse.errorMessage].
  static Widget buildErrorMessage(BuildContext context, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Material(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              Expanded(
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
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
      case LoginMode.ChangeOneTimePassword:
        card = ChangePasswordCard(
          useOTP: mode == LoginMode.ChangeOneTimePassword,
          username: dataMap?[ApiObjectProperty.username],
          password: dataMap?[ApiObjectProperty.password],
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
        // No need for ValueListenableBuilder, as this in the same LayoutBuilder
        card = ManualCard(
          showSettings: showSettingsInCard.value,
          errorMessage: dataMap?[ApiObjectProperty.errorMessage],
        );
        break;
    }
    return card;
  }
}
