import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../model/command/api/set_api_config_command.dart';
import '../../model/command/api/startup_command.dart';
import '../../model/command/ui/open_error_dialog_command.dart';
import '../../model/config/api/api_config.dart';
import '../../routing/locations/settings_location.dart';
import '../camera/qr_parser.dart';
import '../camera/qr_scanner_overlay.dart';
import 'widgets/editor/app_name_editor.dart';
import 'widgets/editor/editor_dialog.dart';
import 'widgets/editor/url_editor.dart';
import 'widgets/setting_group.dart';
import 'widgets/setting_item.dart';

/// Displays all settings of the app
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with UiServiceGetterMixin, ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<int> resolutions = [320, 640, 1024];

  /// Baseurl notifier, will rebuild the value once changed
  late ValueNotifier<String> baseUrlNotifier;

  /// Language notifier, , will rebuild the value once changed
  late ValueNotifier<String> languageNotifier;

  /// App name notifier, will rebuild the value once changed
  late ValueNotifier<String> appNameNotifier;

  /// Picture Size notifier, will rebuild the value once changed
  late ValueNotifier<int> pictureSizeNotifier;

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
    super.initState();
    var appConfig = getConfigService().getAppConfig()!;

    // Application setting
    baseUrlNotifier = ValueNotifier(getConfigService().getBaseUrl() ?? "");
    appNameNotifier = ValueNotifier(getConfigService().getAppName() ?? "");
    languageNotifier = ValueNotifier(getConfigService().getLanguage());
    pictureSizeNotifier = ValueNotifier(getConfigService().getPictureResolution() ?? resolutions.last);

    // Version Info
    appVersionNotifier = ValueNotifier("Loading...");
    if (appConfig.versionConfig.version != null) {
      appVersionNotifier.value = appConfig.versionConfig.version!;
    } else {
      PackageInfo.fromPlatform().then((packageInfo) => appVersionNotifier.value = packageInfo.version);
    }
    commitNotifier = ValueNotifier(appConfig.versionConfig.commit ?? "");
    buildDateNotifier = ValueNotifier(appConfig.versionConfig.buildDate ?? "");
  }

  @override
  void dispose() {
    baseUrlNotifier.dispose();
    appNameNotifier.dispose();
    languageNotifier.dispose();
    pictureSizeNotifier.dispose();
    commitNotifier.dispose();
    buildDateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //If the style changes, for unknown reasons to us, this page gets built when calling
    //setState directly in the changeStyle method of main.dart.
    //A delayed future solved it, but it only happened on some devices.
    //This is the only widget not having a working "mounted" state for route context.
    //TODO investigate low prio
    if (mounted && context.currentBeamLocation.runtimeType == SettingsLocation) {
      getUiService().setRouteContext(pContext: context);
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: context.canBeamBack
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                onPressed: () => context.beamBack(),
              )
            : null,
        title: Text(getConfigService().translateText("Settings")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildApplicationSettings(context), _buildVersionInfo()],
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
                child: getConfigService().getUserInfo() != null
                    ? InkWell(
                        onTap: () => context.beamBack(),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            getConfigService().translateText("CLOSE"),
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
                    child: getConfigService().getUserInfo() != null
                        ? Text(
                            getConfigService().translateText("SAVE"),
                            style:
                                TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
                          )
                        : Text(
                            getConfigService().translateText("OPEN"),
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
      floatingActionButton: !getConfigService().isOffline()
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const FaIcon(FontAwesomeIcons.qrcode),
              onPressed: () => _openQRScanner(),
            )
          : null,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SettingGroup _buildApplicationSettings(BuildContext context) {
    SettingItem appNameSetting = SettingItem(
      frontIcon: FaIcon(
        FontAwesomeIcons.server,
        color: Theme.of(context).primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
      value: appNameNotifier,
      title: getConfigService().translateText("App Name"),
      enabled: !getConfigService().isOffline(),
      onPressed: () {
        TextEditingController controller = TextEditingController(text: appNameNotifier.value);
        Widget editor = AppNameEditor(controller: controller);

        _settingItemClicked(
          pEditor: editor,
          pTitleIcon: FaIcon(
            FontAwesomeIcons.server,
            color: Theme.of(context).primaryColor,
          ),
          pTitleText: getConfigService().translateText("App Name"),
        ).then((value) {
          if (value) {
            appNameNotifier.value = controller.text;
            getConfigService().setAppName(controller.text);
          }
        });
      },
    );

    SettingItem baseUrlSetting = SettingItem(
        frontIcon: FaIcon(
          FontAwesomeIcons.globe,
          color: Theme.of(context).primaryColor,
        ),
        endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
        value: baseUrlNotifier,
        title: getConfigService().translateText("URL"),
        enabled: !getConfigService().isOffline(),
        onPressed: () {
          TextEditingController controller = TextEditingController(text: baseUrlNotifier.value);
          Widget editor = UrlEditor(controller: controller);

          _settingItemClicked(
            pEditor: editor,
            pTitleIcon: FaIcon(
              FontAwesomeIcons.globe,
              color: Theme.of(context).primaryColor,
            ),
            pTitleText: getConfigService().translateText("URL"),
          ).then((value) async {
            if (value) {
              try {
                // Validate format
                var uri = Uri.parse(controller.text);
                await getConfigService().setBaseUrl(uri.toString());
                baseUrlNotifier.value = uri.toString();

                getUiService().sendCommand(SetApiConfigCommand(
                  apiConfig: ApiConfig(serverConfig: getConfigService().getServerConfig()),
                  reason: "Settings url editor",
                ));
              } catch (e) {
                getUiService().sendCommand(OpenErrorDialogCommand(
                  reason: "parseURl",
                  message: getConfigService().translateText("URL text could not be parsed"),
                  canBeFixedInSettings: true,
                ));
              }
            }
          });
        });

    SettingItem languageSetting = SettingItem(
      frontIcon: FaIcon(
        FontAwesomeIcons.language,
        color: Theme.of(context).primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.caretDown),
      title: getConfigService().translateText("Language"),
      value: languageNotifier,
      onPressed: () {
        var supportedLanguages = getConfigService().getSupportedLanguages().toList(growable: false);
        Picker picker = Picker(
            confirmTextStyle: const TextStyle(fontSize: 16),
            cancelTextStyle: const TextStyle(fontSize: 16),
            selecteds: [supportedLanguages.indexOf(languageNotifier.value)],
            adapter: PickerDataAdapter<String>(
              pickerdata: supportedLanguages,
            ),
            onConfirm: (Picker picker, List<int> values) {
              if (values.isNotEmpty) {
                languageNotifier.value = picker.getSelectedValues()[0];
                getConfigService().setLanguage(languageNotifier.value);
              }
            });
        picker.showModal(context, themeData: Theme.of(context));
      },
    );

    SettingItem pictureSetting = SettingItem(
      frontIcon: FaIcon(
        FontAwesomeIcons.image,
        color: Theme.of(context).primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.caretDown),
      title: getConfigService().translateText("Picture Size"),
      value: pictureSizeNotifier,
      itemBuilder: <int>(BuildContext context, int value, Widget? widget) => Text("$value px"),
      onPressed: () {
        Picker picker = Picker(
            selecteds: [resolutions.indexOf(pictureSizeNotifier.value)],
            adapter: PickerDataAdapter<int>(
              data: resolutions.map((e) => PickerItem(text: Text("$e px"), value: e)).toList(growable: false),
            ),
            confirmTextStyle: const TextStyle(fontSize: 16),
            cancelTextStyle: const TextStyle(fontSize: 16),
            onConfirm: (Picker picker, List<int> values) {
              if (values.isNotEmpty) {
                pictureSizeNotifier.value = picker.getSelectedValues()[0];
                getConfigService().setPictureResolution(pictureSizeNotifier.value);
              }
            });
        picker.showModal(context, themeData: Theme.of(context));
      },
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          getConfigService().translateText("Application"),
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
      title: getConfigService().translateText("Github commit"),
    );

    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      value: appVersionNotifier,
      title: getConfigService().translateText("App version"),
    );

    SettingItem buildDataSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.calendar),
      value: buildDateNotifier,
      title: getConfigService().translateText("Build date"),
    );

    SettingGroup group = SettingGroup(
        groupHeader: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            getConfigService().translateText("Version Info"),
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
    getUiService().openDialog(
        pDialogWidget: QRScannerOverlay(callback: (barcode, _) {
          QRAppCode code = QRParser.parseCode(rawQRCode: barcode.rawValue!);
          getConfigService().setAppName(code.appName);
          getConfigService().setBaseUrl(code.url);

          // set local display values
          appNameNotifier.value = code.appName;
          baseUrlNotifier.value = code.url;
          // set username & password for later
          username = code.username;
          password = code.password;

          SetApiConfigCommand apiConfigCommand = SetApiConfigCommand(
            apiConfig: ApiConfig(serverConfig: getConfigService().getServerConfig()),
            reason: "QR Scan replaced url",
          );
          getUiService().sendCommand(apiConfigCommand);
        }),
        pIsDismissible: false);
  }

  /// Will send a [StartupCommand] with current values
  void _saveClicked() {
    getUiService().setRouteContext(pContext: context);

    if (appNameNotifier.value.isNotEmpty && baseUrlNotifier.value.isNotEmpty) {
      StartupCommand startupCommand = StartupCommand(
        reason: "Open App from Settings",
        appName: appNameNotifier.value,
        username: username,
        password: password,
      );
      getUiService().sendCommand(startupCommand);

      username = null;
      password = null;
    } else {
      getUiService().openDialog(
        pDialogWidget: AlertDialog(
          title: Text(getConfigService().translateText("Missing required fields")),
          content: Text(getConfigService().translateText("You have to provide app name and base url to open an app.")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                getConfigService().translateText("Ok"),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        pIsDismissible: true,
      );
    }
  }
}
