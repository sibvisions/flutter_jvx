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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../service/config/config_controller.dart';
import '../../util/parse_util.dart';
import 'app_image.dart';
import 'app_overview_page.dart';

class AppEditDialog extends StatefulWidget {
  final ServerConfig? config;
  final bool predefined;
  final bool locked;

  /// Gets called with either an updated config from the input or a newly generated one.
  final void Function(ServerConfig app) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const AppEditDialog({
    super.key,
    this.config,
    this.predefined = false,
    this.locked = false,
    required this.onSubmit,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  State<AppEditDialog> createState() => _AppEditDialogState();
}

class _AppEditDialogState extends State<AppEditDialog> {
  static Color disabledLightColor = Colors.grey.shade200;

  late final TextEditingController titleController;
  late final TextEditingController appNameController;
  late final TextEditingController baseUrlController;
  bool defaultChecked = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.config?.title);
    appNameController = TextEditingController(text: widget.config?.appName);
    baseUrlController = TextEditingController(text: widget.config?.baseUrl?.toString());
    defaultChecked = widget.config?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData parentTheme = Theme.of(context);

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
            hintStyle: const TextStyle(fontWeight: FontWeight.bold),
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
              bool appNameEnabled = !widget.locked && widget.config == null;
              var isThemeLight = parentTheme.brightness == Brightness.light;

              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (constraints.maxHeight > 450)
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
                              color: appNameEnabled
                                  ? null
                                  : (isThemeLight ? disabledLightColor : parentTheme.disabledColor),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: TextField(
                                  enabled: appNameEnabled,
                                  controller: appNameController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    icon: FaIcon(
                                      FontAwesomeIcons.cubes,
                                      color: appNameEnabled ? null : parentTheme.disabledColor,
                                    ),
                                    labelText: "${FlutterUI.translate("App Name")}*",
                                    border: InputBorder.none,
                                    suffixIcon: appNameEnabled && appNameController.text.isNotEmpty
                                        ? ExcludeFocus(
                                            child: IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () => setState(() => appNameController.clear()),
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
                                  enabled: !widget.locked,
                                  controller: titleController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.title,
                                      color: !widget.locked ? null : parentTheme.disabledColor,
                                    ),
                                    labelText: FlutterUI.translate("Title"),
                                    border: InputBorder.none,
                                    suffixIcon: !widget.locked && titleController.text.isNotEmpty
                                        ? ExcludeFocus(
                                            child: IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () => setState(() => titleController.clear()),
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
                                  enabled: !widget.locked,
                                  controller: baseUrlController,
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (value) => _onSubmit(),
                                  decoration: InputDecoration(
                                    icon: FaIcon(
                                      FontAwesomeIcons.globe,
                                      color: !widget.locked ? null : parentTheme.disabledColor,
                                    ),
                                    labelText: "${FlutterUI.translate("URL")}*",
                                    border: InputBorder.none,
                                    hintText: "http://host:port/services/mobile",
                                    suffixIcon: !widget.locked && baseUrlController.text.isNotEmpty
                                        ? ExcludeFocus(
                                            child: IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () => setState(() => baseUrlController.clear()),
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
                        top: 16,
                        left: 16,
                        child: Icon(
                          Icons.lock,
                          color: parentTheme.colorScheme.error,
                        ),
                      ),
                    if (widget.predefined)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Banner(
                          message: FlutterUI.translate("Provided"),
                          location: BannerLocation.topEnd,
                          color: parentTheme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      actionsAlignment: !widget.locked ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
      actions: !widget.locked
          ? [
              if (widget.config != null)
                TextButton(
                  onPressed: widget.onDelete,
                  child: Text(FlutterUI.translate(widget.predefined ? "Reset" : "Delete")),
                ),
              TextButton(
                onPressed: widget.onCancel,
                child: Text(FlutterUI.translate("Cancel")),
              ),
              TextButton(
                onPressed: _onSubmit,
                child: Text(FlutterUI.translate("OK")),
              ),
            ]
          : [
              TextButton(
                onPressed: widget.onCancel,
                child: Text(FlutterUI.translate("Close")),
              ),
            ],
    );
  }

  Widget _buildDefaultSwitch(BuildContext context, bool value, {GestureTapCallback? onTap}) {
    return Tooltip(
      message: FlutterUI.translate("Whether this app should be auto-started when starting the application"),
      child: Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FlutterUI.translate("Autostart"),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Switch(
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

  Future<void> _onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (appNameController.text.isNotEmpty && baseUrlController.text.isNotEmpty) {
      try {
        // Validate format
        var uri = Uri.parse(baseUrlController.text.trim());
        uri = ParseUtil.appendJVxUrlSuffix(uri);

        var newConfig = ServerConfig(
          appName: ParseUtil.ensureNullOnEmpty(appNameController.text),
          title: ParseUtil.ensureNullOnEmpty(titleController.text),
          baseUrl: uri,
          username: widget.config?.username,
          password: widget.config?.password,
          isDefault: defaultChecked,
        );

        widget.onSubmit.call(newConfig);
      } catch (e, stack) {
        FlutterUI.log.i("User entered invalid URL", e, stack);
        await AppOverviewPage.showInvalidURLDialog(context, e);
      }
    } else {
      await AppOverviewPage.showRequiredFieldsDialog(context);
    }
  }

  String get effectiveEditIconName {
    if (titleController.text.isNotEmpty) {
      return titleController.text;
    } else {
      return widget.config?.title ??
          ConfigController().getAppStyle(appNameController.text)?["login.title"] ??
          appNameController.text;
    }
  }
}
