import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../model/command/api/startup_command.dart';
import '../../model/command/ui/open_error_dialog_command.dart';
import '../camera/qr_parser.dart';
import '../camera/qr_scanner_overlay.dart';
import 'widgets/editor/editor_dialog.dart';
import 'widgets/editor/text_editor.dart';
import 'widgets/setting_group.dart';
import 'widgets/setting_item.dart';

/// Displays all settings of the app
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const double endIconSize = 20;
  static const String urlSuffix = "/services/mobile";

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

  static const double bottomBarHeight = 55;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    // Load Version
    appVersionNotifier = ValueNotifier("${FlutterJVx.translate("Loading")}...");
    PackageInfo.fromPlatform().then((packageInfo) {
      int? buildNumber = IConfigService().getAppConfig()?.versionConfig?.buildNumber;
      return appVersionNotifier.value =
          "${packageInfo.version}-${buildNumber != null && buildNumber >= 0 ? buildNumber : packageInfo.buildNumber}";
    });

    appName = IConfigService().getAppName();
    baseUrl = IConfigService().getBaseUrl();
    language = IConfigService().getUserLanguage();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = SingleChildScrollView(
      child: Column(
        children: [
          _buildApplicationInfo(),
          IconTheme.merge(
            data: IconThemeData(color: Theme.of(context).colorScheme.primary),
            child: Builder(builder: (context) => _buildApplicationSettings(context)),
          ),
          IconTheme.merge(
            data: IconThemeData(color: Theme.of(context).colorScheme.primary),
            child: Builder(builder: (context) => _buildDeviceSettings(context)),
          ),
          _buildVersionInfo(),
          const SizedBox(height: 5),
        ],
      ),
    );

    body = LoadingBar.wrapLoadingBar(body);

    bool loading = LoadingBar.of(context)?.show ?? false;

    return WillPopScope(
      onWillPop: () async => !loading,
      child: Scaffold(
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
        bottomNavigationBar: Material(
          color: Theme.of(context).colorScheme.brightness == Brightness.light
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).bottomAppBarColor,
          child: SafeArea(
            child: SizedBox(
              height: bottomBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _createCancelButton(context, loading)),
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: bottomBarHeight - 2),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          top: -(bottomBarHeight / 10),
                          bottom: -(bottomBarHeight / 10),
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7.0),
                            child: SizedBox(child: _createFAB(context, loading)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _createSaveButton(context, loading)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createCancelButton(BuildContext context, bool loading) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: bottomBarHeight),
      child: context.canBeamBack && _changesPending()
          ? InkWell(
              onTap: loading ? null : context.beamBack,
              child: SizedBox.shrink(
                child: Center(
                  child: Text(
                    FlutterJVx.translate("Cancel"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _createSaveButton(BuildContext context, bool loading) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: bottomBarHeight),
      child: InkWell(
        onTap: loading || IConfigService().isOffline() ? null : _saveClicked,
        child: SizedBox.shrink(
          child: Center(
            child: Text(
              FlutterJVx.translate(
                  IConfigService().getClientId() != null ? (_changesPending() ? "Save" : "OK") : "Open"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _createFAB(BuildContext context, bool loading) {
    return !IConfigService().isOffline()
        ? FloatingActionButton(
            elevation: 0.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: loading ? null : _openQRScanner,
            child: FaIcon(
              FontAwesomeIcons.qrcode,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _buildApplicationInfo() {
    if (IConfigService().getAppConfig()?.privacyPolicy != null) {
      SettingItem privacyPolicy = SettingItem(
        frontIcon: const FaIcon(FontAwesomeIcons.link),
        endIcon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: endIconSize, color: Colors.grey),
        title: FlutterJVx.translate("Privacy Policy"),
        onPressed: (value) => launchUrl(
          IConfigService().getAppConfig()!.privacyPolicy!,
          mode: LaunchMode.externalApplication,
        ),
      );

      return SettingGroup(
        groupHeader: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            FlutterJVx.translate("Info"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        items: [privacyPolicy],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildApplicationSettings(BuildContext context) {
    String appNameTitle = FlutterJVx.translate("App Name");

    SettingItem appNameSetting = SettingItem(
      frontIcon: FaIcon(FontAwesomeIcons.server, color: Theme.of(context).colorScheme.primary),
      endIcon: const FaIcon(FontAwesomeIcons.keyboard, size: endIconSize, color: Colors.grey),
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
        frontIcon: FaIcon(FontAwesomeIcons.globe, color: Theme.of(context).colorScheme.primary),
        endIcon: const FaIcon(FontAwesomeIcons.keyboard, size: endIconSize, color: Colors.grey),
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
            pTitleIcon: const FaIcon(FontAwesomeIcons.globe),
            pTitleText: urlTitle,
          ).then((value) async {
            if (value == true) {
              try {
                // Validate format
                var uri = Uri.parse(controller.text.trim());
                if (!uri.path.endsWith(urlSuffix) && !uri.path.endsWith("$urlSuffix/")) {
                  String appendingSuffix = urlSuffix;
                  if (uri.pathSegments.last.isEmpty) {
                    appendingSuffix = appendingSuffix.substring(1);
                  }
                  uri = uri.replace(path: uri.path + appendingSuffix);
                }
                baseUrl = uri.toString();
                setState(() {});
              } catch (e) {
                await IUiService().sendCommand(OpenErrorDialogCommand(
                  error: e.toString(),
                  message: FlutterJVx.translate("URL is invalid"),
                  reason: "parseURl failed",
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

    SettingItem languageSetting = _buildPickerItem<String>(
      frontIcon: FontAwesomeIcons.language,
      title: "Language",
      //"System" is default
      value: language ?? supportedLanguages[0],
      onPressed: (value) {
        _buildPicker(
          adapter: PickerDataAdapter<String>(pickerdata: supportedLanguages),
          selecteds: [supportedLanguages.indexOf(value!)],
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
          },
        ).showModal(context, themeData: Theme.of(context));
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
      items: [appNameSetting, baseUrlSetting, languageSetting],
    );
  }

  _buildDeviceSettings(BuildContext context) {
    final Map<ThemeMode, String> themeMapping = {
      ThemeMode.system: FlutterJVx.translate("System"),
      ThemeMode.light: FlutterJVx.translate("Light"),
      ThemeMode.dark: FlutterJVx.translate("Dark"),
    };

    var theme = IConfigService().getThemePreference();
    IconData themeIcon = FontAwesomeIcons.sun;
    if (theme == ThemeMode.light) themeIcon = FontAwesomeIcons.solidSun;
    if (theme == ThemeMode.dark) themeIcon = FontAwesomeIcons.solidMoon;

    SettingItem themeSetting = _buildPickerItem<ThemeMode>(
      frontIcon: themeIcon,
      title: "Theme",
      value: theme,
      itemBuilder: (BuildContext context, value, Widget? widget) => Text(themeMapping[value]!),
      onPressed: (value) {
        _buildPicker(
          selecteds: [ThemeMode.values.indexOf(value!)],
          adapter: PickerDataAdapter<String>(
            pickerdata: ThemeMode.values.map((e) => themeMapping[e]).toList(),
          ),
          onConfirm: (Picker picker, List<int> values) {
            if (values.isNotEmpty) {
              theme = themeMapping.entries.firstWhere((entry) => entry.value == picker.getSelectedValues()[0]).key;
              IConfigService().setThemePreference(theme);
              FlutterJVxState.of(context)?.changedTheme();
            }
          },
        ).showModal(context, themeData: Theme.of(context));
      },
    );

    var resolution = IConfigService().getPictureResolution() ?? resolutions.last;
    SettingItem pictureSetting = _buildPickerItem<int>(
      frontIcon: FontAwesomeIcons.image,
      title: "Picture Size",
      value: resolution,
      itemBuilder: <int>(BuildContext context, int value, Widget? widget) => Text(FlutterJVx.translate("$value px")),
      onPressed: (value) {
        _buildPicker(
          selecteds: [resolutions.indexOf(value!)],
          adapter: PickerDataAdapter<String>(
            //Using data breaks theme styling!
            pickerdata: resolutions.map((e) => "$e px").toList(),
          ),
          onConfirm: (Picker picker, List<int> values) {
            if (values.isNotEmpty) {
              resolution = int.parse((picker.getSelectedValues()[0] as String).split(" ")[0]);
              IConfigService().setPictureResolution(resolution);
              setState(() {});
            }
          },
        ).showModal(context, themeData: Theme.of(context));
      },
    );

    return SettingGroup(
      groupHeader: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          FlutterJVx.translate("Device"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      items: [themeSetting, pictureSetting],
    );
  }

  SettingItem _buildPickerItem<T>({
    required IconData frontIcon,
    required String title,
    required T value,
    required Function(T? value) onPressed,
    ValueWidgetBuilder<T>? itemBuilder,
  }) =>
      SettingItem<T>(
        frontIcon: FaIcon(frontIcon, color: Theme.of(context).colorScheme.primary),
        endIcon: const FaIcon(FontAwesomeIcons.circleChevronDown, size: endIconSize, color: Colors.grey),
        title: FlutterJVx.translate(title),
        value: value,
        itemBuilder: itemBuilder,
        onPressed: onPressed,
      );

  Picker _buildPicker({
    required PickerDataAdapter adapter,
    List<int>? selecteds,
    void Function(Picker, List<int>)? onConfirm,
  }) =>
      Picker(
        selecteds: selecteds,
        adapter: adapter,
        onConfirm: onConfirm,
        confirmText: FlutterJVx.translate("Confirm"),
        cancelText: FlutterJVx.translate("Cancel"),
        confirmTextStyle: const TextStyle(fontSize: 16),
        cancelTextStyle: const TextStyle(fontSize: 16),
      );

  Widget _buildVersionInfo() {
    SettingItem appVersionSetting = SettingItem(
      frontIcon: const FaIcon(FontAwesomeIcons.github),
      endIcon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: endIconSize, color: Colors.grey),
      valueNotifier: appVersionNotifier,
      title: FlutterJVx.translate("App Version"),
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

    return SettingGroup(
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

  /// Opens the QR-Scanner and parses the scanned code
  void _openQRScanner() {
    IUiService().openDialog(
      pBuilder: (_) => QRScannerOverlay(callback: (barcode, _) async {
        FlutterJVx.logUI.d("Parsing scanned qr code:\n\n${barcode.rawValue}");
        try {
          QRAppCode code = QRParser.parseCode(barcode.rawValue!);
          appName = code.appName;
          baseUrl = code.url;

          // set username & password for later
          username = code.username;
          password = code.password;

          setState(() {});
        } on FormatException catch (e) {
          FlutterJVx.logUI.w("Error parsing QR Code", e);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(FlutterJVx.translate(e.message)),
          ));
        }
      }),
    );
  }

  bool _changesPending() {
    return appName != IConfigService().getAppName() ||
        baseUrl != IConfigService().getBaseUrl() ||
        language != IConfigService().getUserLanguage();
  }

  /// Will send a [StartupCommand] with current values
  void _saveClicked() async {
    if (appName?.isNotEmpty == true && baseUrl?.isNotEmpty == true) {
      try {
        if (!context.canBeamBack || IConfigService().getClientId() == null || _changesPending()) {
          await IConfigService().setAppName(appName);
          await IConfigService().setBaseUrl(baseUrl);
          await IConfigService().setUserLanguage(language);

          FlutterJVxState.of(FlutterJVx.getCurrentContext())?.restart(
            username: username,
            password: password,
          );
        } else {
          context.beamBack();
        }
      } catch (e, stackTrace) {
        IUiService().handleAsyncError(e, stackTrace);
      } finally {
        username = null;
        password = null;
      }
    } else {
      await IUiService().openDialog(
        pBuilder: (_) => AlertDialog(
          title: Text(FlutterJVx.translate("Missing required fields")),
          content: Text(FlutterJVx.translate("You have to provide an app name and a base url to open an app.")),
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
