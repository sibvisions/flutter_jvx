/*
 * Copyright 2023 SIB Visions GmbH
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../components/editor/text_field/fl_text_field_widget.dart';
import '../../config/qr_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../service/apps/app.dart';
import '../../service/apps/i_app_service.dart';
import '../../util/jvx_colors.dart';
import '../../util/parse_util.dart';
import 'app_image.dart';
import 'app_overview_page.dart';

class AppEditDialog extends StatefulWidget {
  final App? config;
  final bool predefined;
  final bool locked;

  /// Is being called with either an updated version of the provided app or a newly generated config.
  final void Function(ServerConfig config) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback? onLongDelete;

  const AppEditDialog({
    super.key,
    this.config,
    this.predefined = false,
    this.locked = false,
    required this.onSubmit,
    required this.onCancel,
    required this.onDelete,
    this.onLongDelete,
  });

  @override
  State<AppEditDialog> createState() => _AppEditDialogState();
}

class _AppEditDialogState extends State<AppEditDialog> {
  static Color disabledLightColor = Colors.grey.shade200;

  late final Set<String> appIds;
  late final TextEditingController titleController;
  late final TextEditingController appNameController;
  late final TextEditingController baseUrlController;
  bool defaultChecked = false;

  @override
  void initState() {
    super.initState();
    appIds = IAppService().getAppIds();
    titleController = TextEditingController(text: widget.config?.title);
    appNameController = TextEditingController(text: widget.config?.name);
    baseUrlController = TextEditingController(text: widget.config?.baseUrl?.toString());
    defaultChecked = widget.config?.isDefault ?? false;
  }

  bool get appNameIsValid => App.isValidAppName(appNameController.text);

  bool get appAlreadyExists {
    if (appNameController.text.isNotEmpty && baseUrlController.text.isNotEmpty) {
      try {
        var uri = _transformUri(baseUrlController.text);
        String newId =
            App.computeId(appNameController.text, uri.toString(), predefined: widget.config?.predefined ?? false)!;
        return (widget.config == null || widget.config?.id != newId) && appIds.contains(newId);
      } on FormatException catch (_) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData parentTheme = Theme.of(context);
    final List<Widget> actions = _getActions();

    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      content: Theme(
        data: parentTheme.copyWith(
          inputDecorationTheme: parentTheme.inputDecorationTheme.copyWith(
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            hintStyle: const TextStyle(fontWeight: FontWeight.w200),
          ),
          textTheme: parentTheme.textTheme.copyWith(
            titleMedium: parentTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.bold),
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: double.maxFinite),
            child: LayoutBuilder(builder: (context, constraints) {
              var isThemeLight = JVxColors.isLight(parentTheme);
              bool showAppAvatar = constraints.maxHeight >= 450;

              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, showAppAvatar ? 16 : 30, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (showAppAvatar)
                            Center(
                              child: SizedBox(
                                height: 100,
                                child: AppImage(
                                  name: effectiveEditIconName,
                                  image: AppOverviewPage.getAppIcon(widget.config),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: _buildDefaultSwitch(
                              context,
                              defaultChecked,
                              onTap: !widget.locked ? () => setState(() => defaultChecked = !defaultChecked) : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Material(
                              type: MaterialType.card,
                              color: !widget.locked
                                  ? null
                                  : (isThemeLight ? disabledLightColor : parentTheme.disabledColor),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: TextField(
                                  autofocus: widget.config == null,
                                  readOnly: widget.locked,
                                  controller: appNameController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    errorText: !appAlreadyExists
                                        ? (appNameIsValid ? null : FlutterUI.translateLocal("The app name is invalid."))
                                        : FlutterUI.translateLocal("This app already exists."),
                                    icon: FaIcon(
                                      FontAwesomeIcons.cubes,
                                      color: !widget.locked ? null : parentTheme.disabledColor,
                                    ),
                                    labelText: "${FlutterUI.translateLocal("App name")} *",
                                    border: InputBorder.none,
                                    suffixIcon: !widget.locked && appNameController.text.isNotEmpty
                                        ? ExcludeFocus(
                                            child: IconButton(
                                              icon: const Icon(Icons.clear),
                                              tooltip: FlutterUI.translate("Clear"),
                                              onPressed: () => setState(() => appNameController.clear()),
                                              color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                                              iconSize: FlTextFieldWidget.iconSize,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Material(
                              type: MaterialType.card,
                              color: !widget.locked
                                  ? null
                                  : isThemeLight
                                      ? disabledLightColor
                                      : parentTheme.disabledColor,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: TextField(
                                  readOnly: widget.locked,
                                  controller: titleController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.title,
                                      color: !widget.locked ? null : parentTheme.disabledColor,
                                    ),
                                    labelText: FlutterUI.translateLocal("Title"),
                                    border: InputBorder.none,
                                    suffixIcon: !widget.locked && titleController.text.isNotEmpty
                                        ? ExcludeFocus(
                                            child: IconButton(
                                              icon: const Icon(Icons.clear),
                                              tooltip: FlutterUI.translate("Clear"),
                                              onPressed: () => setState(() => titleController.clear()),
                                              color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                                              iconSize: FlTextFieldWidget.iconSize,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Material(
                              type: MaterialType.card,
                              color: !widget.locked
                                  ? null
                                  : isThemeLight
                                      ? disabledLightColor
                                      : parentTheme.disabledColor,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: TextField(
                                  readOnly: widget.locked,
                                  controller: baseUrlController,
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: appAlreadyExists || !appNameIsValid ? null : (value) => _onSubmit(),
                                  decoration: InputDecoration(
                                    errorText:
                                        !appAlreadyExists ? null : FlutterUI.translateLocal("This app already exists."),
                                    icon: FaIcon(
                                      FontAwesomeIcons.globe,
                                      color: !widget.locked ? null : parentTheme.disabledColor,
                                    ),
                                    labelText: "${FlutterUI.translateLocal("URL")} *",
                                    border: InputBorder.none,
                                    hintText: "https://server${ParseUtil.mobileServicePath}",
                                    suffixIcon: !widget.locked && baseUrlController.text.isNotEmpty
                                        ? ExcludeFocus(
                                            child: IconButton(
                                              icon: const Icon(Icons.clear),
                                              tooltip: FlutterUI.translate("Clear"),
                                              onPressed: () => setState(() => baseUrlController.clear()),
                                              color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
                                              iconSize: FlTextFieldWidget.iconSize,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.locked)
                      Positioned(
                        top: 0,
                        left: 20,
                        child: Container(
                          width: 60,
                          height: 40,
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: parentTheme.colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.lock,
                              size: 24,
                              color: parentTheme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Material(
                        elevation: 1,
                        clipBehavior: Clip.hardEdge,
                        color: parentTheme.colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                        ),
                        child: Tooltip(
                          message: FlutterUI.translateLocal(qrCodeError ?? "Show QR Code"),
                          triggerMode: qrCodeError != null ? TooltipTriggerMode.tap : TooltipTriggerMode.longPress,
                          child: InkWell(
                            onTap: qrCodeError == null ? _showQrCodeDialog : null,
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.qr_code,
                                  size: 24,
                                  color: qrCodeError == null ? null : JVxColors.COMPONENT_DISABLED,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.predefined)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Banner(
                          message: FlutterUI.translateLocal("Provided"),
                          location: BannerLocation.topEnd,
                          color: JVxColors.isLightTheme(context) ? parentTheme.colorScheme.primary : Colors.white70,
                          textStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 9.5,
                              color: JVxColors.isLightTheme(context) ? Colors.white: JVxColors.LIGHTER_BLACK),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 12.0),
      actionsAlignment: actions.length > 1 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
      actions: actions,
//      actions: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [actions[0], actions[1], actions[2] ])]

    );
  }

  List<Widget> _getActions() {

    int iCharCount = 0;

    List<Widget> actions = [];

    if (widget.config != null) {
      String resetOrDelete = FlutterUI.translateLocal(widget.predefined ? "Reset" : "Delete");

      iCharCount += resetOrDelete.length;

      actions.add(TextButton(
        onPressed: widget.onDelete,
        onLongPress: widget.onLongDelete,
        style: TextButton.styleFrom(foregroundColor: Theme
            .of(context)
            .colorScheme
            .error),
        child: Text(resetOrDelete),
      ));
    }

    if (!widget.locked) {
      String cancel = FlutterUI.translateLocal("Cancel");
      String ok = FlutterUI.translateLocal("OK");

      iCharCount += cancel.length + ok.length;

      actions.addAll([
        TextButton(
          onPressed: widget.onCancel,
          child: Text(cancel),
        ),
        TextButton(
          onPressed: appAlreadyExists || !appNameIsValid ? null : _onSubmit,
          child: Text(ok),
        ),
      ]);
    } else {
      String close = FlutterUI.translateLocal("Close");

      iCharCount += close.length;

      actions.add(TextButton(
        onPressed: widget.onCancel,
        child: Text(close),
      ));
    }

    //otherwise actions would be in separate lines
    if (actions.length > 2 && iCharCount > 22) {
      actions = [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [actions[0]]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(children: [actions[1]]),
          Column(children: [actions[2]])])
      ];
    }

    return actions;
  }

  Widget _buildDefaultSwitch(BuildContext context, bool value, {GestureTapCallback? onTap}) {
    return Tooltip(
      message: FlutterUI.translateLocal("Whether this app should be auto-started when starting the application."),
      child: Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FlutterUI.translateLocal("Auto start"),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Switch.adaptive(
              inactiveThumbColor: onTap != null ? Theme.of(context).colorScheme.primary : null,
              inactiveTrackColor: onTap != null ? Theme.of(context).colorScheme.surface : null,
              value: value,
              onChanged: onTap != null ? (bool? value) => onTap.call() : null,
            ),
          ],
        ),
      ),
    );
  }

  Uri _transformUri(String url) {
    return ParseUtil.appendMobileServicePath(Uri.parse(url.trim()));
  }

  Future<void> _onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    var appName = appNameController.text.trim();
    var baseUrl = baseUrlController.text.trim();
    if (appName.isNotEmpty && baseUrl.isNotEmpty) {
      try {
        var newConfig = ServerConfig(
          appName: ParseUtil.ensureNullOnEmpty(appName),
          title: ParseUtil.ensureNullOnEmpty(titleController.text.trim()),
          baseUrl: _transformUri(baseUrl),
          username: widget.config?.username,
          password: widget.config?.password,
          icon: widget.config?.icon,
          isDefault: defaultChecked,
        );

        widget.onSubmit.call(newConfig);
      } on FormatException catch (e, stack) {
        FlutterUI.log.i("User entered invalid URL", error: e, stackTrace: stack);
        await AppOverviewPage.showInvalidURLDialog(context, e);
      }
    } else {
      await AppOverviewPage.showRequiredFieldsDialog(context);
    }
  }

  String get effectiveEditIconName {
    if (titleController.text.trim().isNotEmpty) {
      return titleController.text.trim();
    } else {
      return widget.config?.title ?? widget.config?.applicationStyle?["login.title"] ?? appNameController.text.trim();
    }
  }

  String? get qrCodeError {
    String appName = appNameController.text.trim();
    String baseUrl = baseUrlController.text.trim();
    if (appName.isEmpty) {
      return "You need to enter an app name.";
    } else if (baseUrl.isEmpty) {
      return "You need to enter an URL.";
    }

    return null;
  }

  void _showQrCodeDialog() {
    String appName = appNameController.text.trim();
    String baseUrl = baseUrlController.text.trim();
    String title = titleController.text.trim();
    String? icon = widget.config?.icon;
    Uri uri = _transformUri(baseUrl);

    try {
      ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(const Size.square(300)),
            child: QrImageView(
              data: QRConfig.generateQrCode(
                ServerConfig(
                  appName: appName,
                  baseUrl: uri,
                  title: ParseUtil.ensureNullOnEmpty(title),
                  username: widget.config?.username,
                  password: widget.config?.password,
                  icon: icon,
                ),
              ),
              // gap-less looks kinda cheesy in web
              gapless: !kIsWeb,
              backgroundColor: Colors.white,
              version: QrVersions.auto,
            ),
          ),
        );
      },
    ).whenComplete(() {
      try {
        ScreenBrightness().resetApplicationScreenBrightness();
      } catch (_) {}
    });
  }
}
