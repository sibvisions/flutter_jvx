import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_client/src/mask/camera/qr_parser.dart';
import 'package:flutter_client/src/mask/camera/qr_scanner_mask.dart';
import 'package:flutter_client/src/mask/setting/widgets/editor/app_name_editor.dart';
import 'package:flutter_client/src/mask/setting/widgets/editor/editor_dialog.dart';
import 'package:flutter_client/src/mask/setting/widgets/editor/url_editor.dart';
import 'package:flutter_client/src/mask/setting/widgets/setting_group.dart';
import 'package:flutter_client/src/mask/setting/widgets/setting_item.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/set_api_config_command.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'package:flutter_client/src/model/config/api/url_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../mixin/ui_service_mixin.dart';

/// Displays all settings of the app
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with UiServiceMixin, ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Application settings
  late SettingGroup baseSettings;

  /// Baseurl notifier, will rebuild the value once changed
  late ValueNotifier<String> baseUrlNotifier;

  /// Language notifier, , will rebuild the value once changed
  late ValueNotifier<String> languageNotifier;

  /// App name notifier, will rebuild the value once changed
  late ValueNotifier<String> appNameNotifier;

  /// Version Info
  late SettingGroup versionInfo;

  /// Commit notifier
  late ValueNotifier<String> commitNotifier;

  /// App version notifier
  late ValueNotifier<String> appVersionNotifier;

  /// Build date notifier
  late ValueNotifier<String> buildDateNotifier;

  /// Username of a scanned QR-Code
  String? username;

  /// Password of a scanned QR-Code
  String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    // Application setting
    baseUrlNotifier = ValueNotifier(configService.getApiConfig().urlConfig.getBasePath());
    appNameNotifier = ValueNotifier(configService.getAppName());
    languageNotifier = ValueNotifier("ToDo");

    // Version Info
    // ToDo get real version info
    appVersionNotifier = ValueNotifier("0.5");
    commitNotifier = ValueNotifier("akV83k5");
    buildDateNotifier = ValueNotifier("16.03.2022");

    baseSettings = _buildApplicationSettings();
    versionInfo = _buildVersionInfo();
    super.initState();
  }

  @override
  void dispose() {
    baseUrlNotifier.dispose();
    languageNotifier.dispose();
    appNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    uiService.setRouteContext(pContext: context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => context.beamBack(),
        ),
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [baseSettings, versionInfo],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          child: const Text("Save"),
          onPressed: _saveClicked,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const FaIcon(FontAwesomeIcons.qrcode),
        onPressed: () => _openQRScanner(),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SettingGroup _buildApplicationSettings() {
    SettingItem appNameSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.server),
      endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
      value: appNameNotifier,
      title: "App name",
      onPressed: () {
        TextEditingController controller = TextEditingController(text: appNameNotifier.value);
        Widget editor = AppNameEditor(controller: controller);

        _settingItemClicked(
          pEditor: editor,
          pTitleIcon: const FaIcon(FontAwesomeIcons.server),
          pTitleText: "AppName",
        ).then((value) {
          if (value) {
            appNameNotifier.value = controller.text;
            configService.setAppName(controller.text);
          }
        });
      },
    );

    SettingItem baseUrlSetting = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.globe),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: baseUrlNotifier,
        title: "URL",
        onPressed: () {
          TextEditingController controller = TextEditingController(text: baseUrlNotifier.value);
          Widget editor = UrlEditor(controller: controller);

          _settingItemClicked(
            pEditor: editor,
            pTitleIcon: const FaIcon(FontAwesomeIcons.globe),
            pTitleText: "URL",
          ).then((value) {
            if (value) {
              try {
                UrlConfig config = UrlConfig.fromFullString(fullPath: controller.text);

                baseUrlNotifier.value = config.getBasePath();
                configService.getApiConfig().urlConfig = config;
                uiService.sendCommand(SetApiConfigCommand(apiConfig: configService.getApiConfig(), reason: "Settings url editor"));
              } catch (e) {
                // uiService.sendCommand(OpenErrorDialogCommand(reason: "parseURl", message: "URL text could not be parsed"));
                rethrow;
              }
            }
          });
        });

    SettingItem languageSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.language),
      endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
      value: languageNotifier,
      title: "Language",
    );

    return SettingGroup(
      groupHeader: const Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
          "Application",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      items: [appNameSetting, baseUrlSetting, languageSetting],
    );
  }

  SettingGroup _buildVersionInfo() {
    SettingItem commitSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.codeBranch),
      value: commitNotifier,
      title: "Github commit",
    );

    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      value: appVersionNotifier,
      title: "App version",
    );

    SettingItem buildDataSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.calendar),
      value: buildDateNotifier,
      title: "Build date",
    );

    SettingGroup group = SettingGroup(
        groupHeader: const Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Text(
            "Version Info",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        items: [commitSetting, appVersionSetting, buildDataSetting]);

    return group;
  }

  Future<bool?> _settingItemClicked<bool>({required Widget pEditor, required FaIcon pTitleIcon, required String pTitleText}) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return EditorDialog(
            editor: pEditor,
            titleIcon: pTitleIcon,
            titleText: pTitleText,
          );
        },
        barrierDismissible: false);
  }

  /// Opens the QR-Scanner,
  /// parses scanned code and saves values to config service
  void _openQRScanner() {
    uiService.openDialog(
        pDialogWidget: QRScannerMask(callBack: (barcode, _) {
          QRAppCode code = QRParser.parseCode(rawQRCode: barcode.rawValue!);
          // set service values
          configService.setAppName(code.appName);

          var a = UrlConfig.fromFullString(fullPath: code.url);

          configService.getApiConfig().urlConfig = a;

          // set local display values
          appNameNotifier.value = code.appName;
          baseUrlNotifier.value = code.url;
          // set username & password for later
          username = code.username;
          password = code.password;

          SetApiConfigCommand apiConfigCommand =
              SetApiConfigCommand(apiConfig: configService.getApiConfig(), reason: "QR Scan replaced url");
          uiService.sendCommand(apiConfigCommand);
        }),
        pIsDismissible: false);
  }

  /// Will send a [StartupCommand] with current values
  void _saveClicked() {
    StartupCommand startupCommand = StartupCommand(reason: "QR-Code-Scanned", password: password, username: username);
    uiService.sendCommand(startupCommand);
    password = null;
    username = null;
  }
}
