import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../model/command/api/startup_command.dart';
import '../../model/command/ui/view/message/open_error_dialog_command.dart';
import '../camera/qr_parser.dart';
import '../camera/qr_scanner_overlay.dart';
import '../loading_bar.dart';
import 'widgets/editor/editor_dialog.dart';
import 'widgets/editor/text_editor.dart';
import 'widgets/setting_group.dart';
import 'widgets/setting_item.dart';

/// Displays all settings of the app
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<int> resolutions = [320, 640, 1024];

  /// App version notifier
  late ValueNotifier<String> appVersionNotifier;

  /// Username of a scanned QR-Code
  String? username;

  /// Password of a scanned QR-Code
  String? password;

  String? appName;
  String? baseUrl;
  String? language;
  late int resolution;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    // Load Version
    appVersionNotifier = ValueNotifier("${FlutterJVx.translate("Loading")}...");
    PackageInfo.fromPlatform().then((packageInfo) => appVersionNotifier.value = packageInfo.version);

    appName = IConfigService().getAppName();
    baseUrl = IConfigService().getBaseUrl();
    language = IConfigService().getUserLanguage();
    resolution = IConfigService().getPictureResolution() ?? resolutions.last;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = SingleChildScrollView(
      child: Column(
        children: [
          _buildApplicationSettings(context),
          _buildVersionInfo(),
          Container(
            height: 50,
          )
        ],
      ),
    );

    body = LoadingBar.wrapLoadingBar(body);

    bool loading = LoadingBar.of(context)?.show ?? false;

    return WillPopScope(
      onWillPop: () async => !loading,
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: context.canBeamBack
                ? IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                    onPressed: !loading ? context.beamBack : null,
                  )
                : null,
            title: Text(FlutterJVx.translate("Settings")),
            elevation: 0,
          ),
          body: body,
          bottomNavigationBar: BottomAppBar(
            elevation: 0.0,
            shape: const CircularNotchedRectangle(),
            color: Theme.of(context).primaryColor,
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: IConfigService().getUserInfo() != null && context.canBeamBack
                        ? InkWell(
                            onTap: loading ? null : context.beamBack,
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                FlutterJVx.translate("Cancel"),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: loading || IConfigService().isOffline() ? null : _saveClicked,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          FlutterJVx.translate(IConfigService().getUserInfo() != null ? "Save" : "Open"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: !IConfigService().isOffline()
              ? FloatingActionButton(
                  elevation: 0.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: loading ? null : _openQRScanner,
                  child: const FaIcon(FontAwesomeIcons.qrcode),
                )
              : null,
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _buildApplicationSettings(BuildContext context) {
    String appNameTitle = FlutterJVx.translate("App Name");

    SettingItem appNameSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.server),
      endIcon: const FaIcon(FontAwesomeIcons.keyboard),
      value: appName ?? "",
      title: appNameTitle,
      enabled: !IConfigService().isOffline(),
      onPressed: (value) {
        TextEditingController controller = TextEditingController(text: value);

        _showEditor(
          context,
          pEditorBuilder: (context, onConfirm) => TextEditor(
            title: appNameTitle,
            hintText: FlutterJVx.translate("Enter new App Name"),
            controller: controller,
            onConfirm: onConfirm,
          ),
          controller: controller,
          pTitleIcon: const FaIcon(FontAwesomeIcons.server),
          pTitleText: appNameTitle,
        ).then((value) {
          if (value == true) {
            appName = controller.text.trim();
            setState(() {});
          }
        });
      },
    );

    String urlTitle = FlutterJVx.translate("URL");
    SettingItem baseUrlSetting = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.globe),
        endIcon: const FaIcon(FontAwesomeIcons.keyboard),
        value: baseUrl ?? "",
        title: urlTitle,
        enabled: !IConfigService().isOffline(),
        onPressed: (value) {
          TextEditingController controller = TextEditingController(text: value);

          _showEditor(
            context,
            pEditorBuilder: (context, onConfirm) => TextEditor(
              title: urlTitle,
              hintText: "http://host:port/services/mobile",
              controller: controller,
              onConfirm: onConfirm,
            ),
            controller: controller,
            pTitleIcon: FaIcon(
              FontAwesomeIcons.globe,
              color: Theme.of(context).primaryColor,
            ),
            pTitleText: urlTitle,
          ).then((value) async {
            if (value == true) {
              try {
                // Validate format
                var uri = Uri.parse(controller.text.trim());
                baseUrl = uri.toString();
                setState(() {});
              } catch (e) {
                await IUiService().sendCommand(OpenErrorDialogCommand(
                  reason: "parseURl",
                  message: FlutterJVx.translate("URL text could not be parsed"),
                  canBeFixedInSettings: true,
                ));
              }
            }
          });
        });

    var supportedLanguages = IConfigService().getSupportedLanguages().toList();
    supportedLanguages.insertAll(0, [
      "${FlutterJVx.translate("System")} (${IConfigService.getPlatformLocale()})",
      "en",
    ]);

    SettingItem languageSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.language),
      endIcon: const FaIcon(FontAwesomeIcons.circleChevronDown),
      title:
          "${FlutterJVx.translate("Language")} (${FlutterJVx.translate("Current")}: ${IConfigService().getDisplayLanguage()})",
      //"System" is default
      value: language ?? supportedLanguages[0],
      onPressed: (value) {
        Picker picker = Picker(
            cancelText: FlutterJVx.translate("Cancel"),
            confirmText: FlutterJVx.translate("Confirm"),
            confirmTextStyle: const TextStyle(fontSize: 16),
            cancelTextStyle: const TextStyle(fontSize: 16),
            selecteds: [supportedLanguages.indexOf(value)],
            adapter: PickerDataAdapter<String>(
              pickerdata: supportedLanguages,
            ),
            onConfirm: (Picker picker, List<int> values) {
              if (values.isNotEmpty) {
                String? selectedLanguage = picker.getSelectedValues()[0];
                if (selectedLanguage == supportedLanguages[0]) {
                  //"System" selected
                  selectedLanguage = null;
                }
                language = selectedLanguage;
                setState(() {});
              }
            });
        picker.showModal(context, themeData: Theme.of(context));
      },
    );

    SettingItem pictureSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.image),
      endIcon: const FaIcon(FontAwesomeIcons.circleChevronDown),
      title: FlutterJVx.translate("Picture Size"),
      value: resolution,
      itemBuilder: <int>(BuildContext context, int value, Widget? widget) => Text(FlutterJVx.translate("$value px")),
      onPressed: (value) {
        Picker picker = Picker(
            cancelText: FlutterJVx.translate("Cancel"),
            confirmText: FlutterJVx.translate("Confirm"),
            selecteds: [resolutions.indexOf(value)],
            adapter: PickerDataAdapter<int>(
              data: resolutions.map((e) => PickerItem(text: Text("$e px"), value: e)).toList(growable: false),
            ),
            confirmTextStyle: const TextStyle(fontSize: 16),
            cancelTextStyle: const TextStyle(fontSize: 16),
            onConfirm: (Picker picker, List<int> values) {
              if (values.isNotEmpty) {
                resolution = picker.getSelectedValues()[0];
                setState(() {});
              }
            });
        picker.showModal(context, themeData: Theme.of(context));
      },
    );

    return ListTileTheme.merge(
      iconColor: Theme.of(context).colorScheme.primary,
      child: SettingGroup(
        groupHeader: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            FlutterJVx.translate("Application"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        items: [appNameSetting, baseUrlSetting, languageSetting, pictureSetting],
      ),
    );
  }

  SettingGroup _buildVersionInfo() {
    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      endIcon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare),
      valueNotifier: appVersionNotifier,
      title: FlutterJVx.translate("App version"),
      onPressed: (value) => showLicensePage(
        context: context,
        applicationIcon: Image(
          image: Svg(
            ImageLoader.getAssetPath(
              FlutterJVx.package,
              "assets/images/J.svg",
            ),
          ),
        ),
      ),
    );

    SettingItem commitSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.codeBranch),
      value: IConfigService().getAppConfig()?.versionConfig?.commit ?? "",
      title: FlutterJVx.translate("RCS"),
    );

    SettingItem buildDataSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.calendar),
      value: IConfigService().getAppConfig()?.versionConfig?.buildDate ?? "",
      title: FlutterJVx.translate("Build date"),
    );

    SettingGroup group = SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterJVx.translate("Version Info"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [appVersionSetting, commitSetting, buildDataSetting],
    );

    return group;
  }

  Future<bool?> _showEditor<bool>(
    BuildContext context, {
    required String pTitleText,
    required FaIcon pTitleIcon,
    required EditorBuilder pEditorBuilder,
    required TextEditingController controller,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => EditorDialog(
        titleText: pTitleText,
        titleIcon: pTitleIcon,
        editorBuilder: pEditorBuilder,
        controller: controller,
      ),
      barrierDismissible: false,
    );
  }

  /// Opens the QR-Scanner,
  /// parses scanned code and saves values to config service
  void _openQRScanner() {
    IUiService().openDialog(
      pBuilder: (_) => QRScannerOverlay(callback: (barcode, _) async {
        QRAppCode code = QRParser.parseCode(rawQRCode: barcode.rawValue!);
        appName = code.appName;
        baseUrl = code.url;

        // set username & password for later
        username = code.username;
        password = code.password;

        setState(() {});
      }),
    );
  }

  /// Will send a [StartupCommand] with current values
  void _saveClicked() async {
    if (appName?.isNotEmpty == true && baseUrl?.isNotEmpty == true) {
      try {
        await IConfigService().setAppName(appName);
        await IConfigService().setBaseUrl(baseUrl);
        await IConfigService().setUserLanguage(language);
        await IConfigService().setPictureResolution(resolution);

        await ICommandService().sendCommand(StartupCommand(
          reason: "Open App from Settings",
          username: username,
          password: password,
        ));
      } catch (e, stackTrace) {
        IUiService().handleAsyncError(e, stackTrace);
      } finally {
        username = null;
        password = null;
        setState(() {});
      }
    } else {
      await IUiService().openDialog(
        pBuilder: (_) => AlertDialog(
          title: Text(FlutterJVx.translate("Missing required fields")),
          content: Text(FlutterJVx.translate("You have to provide app name and base url to open an app.")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                FlutterJVx.translate("Ok"),
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
