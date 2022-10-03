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
import 'widgets/editor/app_name_editor.dart';
import 'widgets/editor/editor_dialog.dart';
import 'widgets/editor/url_editor.dart';
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

  String? originalAppName = IConfigService().getAppName();
  String? originalBaseUrl = IConfigService().getBaseUrl();
  String originalLanguage = IConfigService().getLanguage();
  int? originalResolution = IConfigService().getPictureResolution();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    // Load Version
    appVersionNotifier = ValueNotifier("${FlutterJVx.translate("Loading")}...");
    PackageInfo.fromPlatform().then((packageInfo) => appVersionNotifier.value = packageInfo.version);
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
                            onTap: loading ? null : closeClicked,
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                FlutterJVx.translate("Close"),
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
                          FlutterJVx.translate("Open"),
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
    SettingItem appNameSetting = SettingItem(
      frontIcon: FaIcon(
        FontAwesomeIcons.server,
        color: Theme.of(context).primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.arrowRight),
      value: IConfigService().getAppName() ?? "",
      title: FlutterJVx.translate("App Name"),
      enabled: !IConfigService().isOffline(),
      onPressed: (value) {
        TextEditingController controller = TextEditingController(text: value);
        Widget editor = AppNameEditor(controller: controller);

        _settingItemClicked(
          pEditor: editor,
          pTitleIcon: FaIcon(
            FontAwesomeIcons.server,
            color: Theme.of(context).primaryColor,
          ),
          pTitleText: FlutterJVx.translate("App Name"),
        ).then((value) async {
          if (value == true) {
            await IConfigService().setAppName(controller.text);
            setState(() {});
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
        value: IConfigService().getBaseUrl() ?? "",
        title: FlutterJVx.translate("URL"),
        enabled: !IConfigService().isOffline(),
        onPressed: (value) {
          TextEditingController controller = TextEditingController(text: value);
          Widget editor = UrlEditor(controller: controller);

          _settingItemClicked(
            pEditor: editor,
            pTitleIcon: FaIcon(
              FontAwesomeIcons.globe,
              color: Theme.of(context).primaryColor,
            ),
            pTitleText: FlutterJVx.translate("URL"),
          ).then((value) async {
            if (value == true) {
              try {
                // Validate format
                var uri = Uri.parse(controller.text);
                await IConfigService().setBaseUrl(uri.toString());
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

    SettingItem languageSetting = SettingItem(
      frontIcon: FaIcon(
        FontAwesomeIcons.language,
        color: Theme.of(context).primaryColor,
      ),
      endIcon: const FaIcon(FontAwesomeIcons.caretDown),
      title: FlutterJVx.translate("Language"),
      value: IConfigService().getLanguage(),
      onPressed: (value) {
        var supportedLanguages = IConfigService().getSupportedLanguages().toList(growable: false);
        Picker picker = Picker(
            confirmTextStyle: const TextStyle(fontSize: 16),
            cancelTextStyle: const TextStyle(fontSize: 16),
            selecteds: [supportedLanguages.indexOf(value)],
            adapter: PickerDataAdapter<String>(
              pickerdata: supportedLanguages,
            ),
            onConfirm: (Picker picker, List<int> values) {
              if (values.isNotEmpty) {
                IConfigService().setLanguage(picker.getSelectedValues()[0]);
                setState(() {});
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
      title: FlutterJVx.translate("Picture Size"),
      value: IConfigService().getPictureResolution() ?? resolutions.last,
      itemBuilder: <int>(BuildContext context, int value, Widget? widget) => Text(FlutterJVx.translate("$value px")),
      onPressed: (value) {
        Picker picker = Picker(
            selecteds: [resolutions.indexOf(value)],
            adapter: PickerDataAdapter<int>(
              data: resolutions.map((e) => PickerItem(text: Text("$e px"), value: e)).toList(growable: false),
            ),
            confirmTextStyle: const TextStyle(fontSize: 16),
            cancelTextStyle: const TextStyle(fontSize: 16),
            onConfirm: (Picker picker, List<int> values) {
              if (values.isNotEmpty) {
                IConfigService().setPictureResolution(picker.getSelectedValues()[0]);
                setState(() {});
              }
            });
        picker.showModal(context, themeData: Theme.of(context));
      },
    );

    return SettingGroup(
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
    );
  }

  SettingGroup _buildVersionInfo() {
    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      valueNotifier: appVersionNotifier,
      title: FlutterJVx.translate("App version"),
      onPressed: (value) => showLicensePage(
        context: context,
        applicationIcon: Image(
          image: Svg(
            ImageLoader.getAssetPath(
              FlutterJVx.package,
              'assets/images/J.svg',
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
    IUiService().openDialog(
      pBuilder: (_) => QRScannerOverlay(callback: (barcode, _) async {
        QRAppCode code = QRParser.parseCode(rawQRCode: barcode.rawValue!);
        await IConfigService().setAppName(code.appName);
        await IConfigService().setBaseUrl(code.url);

        // set username & password for later
        username = code.username;
        password = code.password;

        setState(() {});
      }),
    );
  }

  /// Will send a [StartupCommand] with current values
  void _saveClicked() async {
    if (IConfigService().getAppName()?.isNotEmpty == true && IConfigService().getBaseUrl()?.isNotEmpty == true) {
      try {
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

  void closeClicked() {
    IConfigService().setAppName(originalAppName);
    IConfigService().setBaseUrl(originalBaseUrl);
    IConfigService().setLanguage(originalLanguage);
    IConfigService().setPictureResolution(originalResolution ?? resolutions.last);

    context.beamBack();
  }
}
