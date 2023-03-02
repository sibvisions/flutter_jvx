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
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                hintStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
          textTheme: Theme.of(context).textTheme.copyWith(
                titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.bold),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Center(
                        child: SizedBox(
                          height: 100,
                          child: AppImage(
                            name: widget.config?.effectiveTitle,
                            image: AppOverviewPage.getAppIcon(widget.config),
                          ),
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
                        color: !widget.locked && widget.config == null ? null : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            enabled: !widget.locked && widget.config == null,
                            controller: appNameController,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              icon: const FaIcon(FontAwesomeIcons.cubes),
                              labelText: "${FlutterUI.translate("App Name")}*",
                              border: InputBorder.none,
                              suffixIcon: !widget.locked && widget.config == null && appNameController.text.isNotEmpty
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
                        color: !widget.locked ? null : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            enabled: !widget.locked,
                            controller: titleController,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.title),
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
                        color: !widget.locked ? null : Colors.grey.shade400,
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
                              icon: const FaIcon(FontAwesomeIcons.globe),
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
                if (widget.locked)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Icon(
                      Icons.lock,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                if (widget.predefined)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Tooltip(
                      message: FlutterUI.translate(
                          "This app is provided by your current installation and cannot be removed."),
                      child: Badge(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        largeSize: 24.0,
                        label: Text(FlutterUI.translate("Provided")),
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
              FlutterUI.translate("Start by default"),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Switch(
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

        var newConfig = (widget.config ?? const ServerConfig.empty()).merge(
          ServerConfig(
            title: ParseUtil.ensureNullOnEmpty(titleController.text),
            appName: ParseUtil.ensureNullOnEmpty(appNameController.text),
            baseUrl: uri,
            isDefault: defaultChecked,
          ),
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
}
