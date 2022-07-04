import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
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
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/model/config/api/url_config.dart';
import 'package:flutter_picker/flutter_picker.dart';
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

  /// Picture Size notifier, will rebuild the value once changed
  late ValueNotifier<String> pictureSizeNotifier;

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
    languageNotifier = ValueNotifier(configService.getLanguage());
    pictureSizeNotifier = ValueNotifier("ToDo");

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
    if (mounted) {
      uiService.setRouteContext(pContext: context);
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => context.beamBack(),
        ),
        title: Text(configService.translateText("Settings")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [baseSettings, versionInfo],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Theme.of(context).primaryColor,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: configService.getUserInfo() != null
                    ? InkWell(
                        onTap: () => context.beamBack(),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            configService.translateText("CLOSE"),
                            style:
                                TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      )
                    : Container(),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _saveClicked(),
                  child: Container(
                    alignment: Alignment.center,
                    child: configService.getUserInfo() != null
                        ? Text(
                            configService.translateText("SAVE"),
                            style:
                                TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
                          )
                        : Text(
                            configService.translateText("OPEN"),
                            style:
                                TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                  ),
                ),
              ),
            ],
          ),
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
      frontIcon: FaIcon(
        FontAwesomeIcons.server,
        color: themeData.primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
      value: appNameNotifier,
      title: configService.translateText("App Name"),
      onPressed: () {
        TextEditingController controller = TextEditingController(text: appNameNotifier.value);
        Widget editor = AppNameEditor(controller: controller);

        _settingItemClicked(
          pEditor: editor,
          pTitleIcon: FaIcon(
            FontAwesomeIcons.server,
            color: themeData.primaryColor,
          ),
          pTitleText: configService.translateText("App Name"),
        ).then((value) {
          if (value) {
            appNameNotifier.value = controller.text;
            configService.setAppName(controller.text);
          }
        });
      },
    );

    SettingItem baseUrlSetting = SettingItem(
        frontIcon: FaIcon(
          FontAwesomeIcons.globe,
          color: themeData.primaryColor,
        ),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: baseUrlNotifier,
        title: configService.translateText("URL"),
        onPressed: () {
          TextEditingController controller = TextEditingController(text: baseUrlNotifier.value);
          Widget editor = UrlEditor(controller: controller);

          _settingItemClicked(
            pEditor: editor,
            pTitleIcon: FaIcon(
              FontAwesomeIcons.globe,
              color: themeData.primaryColor,
            ),
            pTitleText: configService.translateText("URL"),
          ).then((value) {
            if (value) {
              try {
                UrlConfig config = UrlConfig.fromFullString(fullPath: controller.text);

                baseUrlNotifier.value = config.getBasePath();
                configService.getApiConfig().urlConfig = config;
                uiService.sendCommand(
                    SetApiConfigCommand(apiConfig: configService.getApiConfig(), reason: "Settings url editor"));
              } catch (e) {
                uiService.sendCommand(OpenErrorDialogCommand(
                    reason: "parseURl", message: configService.translateText("URL text could not be parsed")));
              }
            }
          });
        });

    SettingItem languageSetting = SettingItem(
      frontIcon: FaIcon(
        FontAwesomeIcons.language,
        color: themeData.primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
      value: languageNotifier,
      title: configService.translateText("Language"),
      onPressed: () {
        Picker picker = Picker(
            confirmTextStyle: const TextStyle(fontSize: 14),
            cancelTextStyle: const TextStyle(fontSize: 14),
            adapter: PickerDataAdapter<String>(pickerdata: configService.getSupportedLang()),
            columnPadding: const EdgeInsets.all(8),
            onConfirm: (Picker picker, List value) {
              languageNotifier.value = picker.getSelectedValues()[0];
              configService.setLanguage(picker.getSelectedValues()[0]);
            });
        picker.showModal(context, themeData: themeData);
      },
    );

    SettingItem pictureSetting = SettingItem(
      frontIcon: FaIcon(
        FontAwesomeIcons.image,
        color: themeData.primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
      value: pictureSizeNotifier,
      title: configService.translateText("Big"),
      onPressed: () {
        Picker picker = Picker(
            adapter: PickerDataAdapter<int>(data: [
              PickerItem(text: const Text('320 px'), value: 320),
              PickerItem(text: const Text('640 px'), value: 640),
              PickerItem(text: const Text('1024 px'), value: 1024)
            ]),
            confirmTextStyle: const TextStyle(fontSize: 14),
            cancelTextStyle: const TextStyle(fontSize: 14),
            onConfirm: (Picker picker, List value) {
              int? size;

              if (value.isNotEmpty) {
                size = picker.getSelectedValues()[0];
              }
              print(size.toString());
              //TODO Set the Size
            });
        picker.showModal(context, themeData: themeData);
      },
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          configService.translateText("Application"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [appNameSetting, baseUrlSetting, languageSetting, pictureSetting],
    );
  }

  SettingGroup _buildVersionInfo() {
    SettingItem commitSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.codeBranch),
      value: commitNotifier,
      title: configService.translateText("Github commit"),
    );

    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      value: appVersionNotifier,
      title: configService.translateText("App version"),
    );

    SettingItem buildDataSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.calendar),
      value: buildDateNotifier,
      title: configService.translateText("Build date"),
    );

    SettingGroup group = SettingGroup(
        groupHeader: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            configService.translateText("Version Info"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        items: [commitSetting, appVersionSetting, buildDataSetting]);

    return group;
  }

  Future<bool?> _settingItemClicked<bool>(
      {required Widget pEditor, required FaIcon pTitleIcon, required String pTitleText}) {
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
    StartupCommand startupCommand = StartupCommand(
      reason: "QR-Code-Scanned",
      password: password,
      username: username,
      language: configService.getLanguage(),
      authKey: configService.getAuthCode(),
    );
    uiService.sendCommand(startupCommand);

    password = null;
    username = null;
  }
}
