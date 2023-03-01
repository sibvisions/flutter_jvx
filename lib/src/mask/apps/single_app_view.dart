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

class SingleAppView extends StatefulWidget {
  final ServerConfig? config;
  final void Function(ServerConfig config) onStart;

  const SingleAppView({
    super.key,
    this.config,
    required this.onStart,
  });

  @override
  State<SingleAppView> createState() => _SingleAppViewState();
}

class _SingleAppViewState extends State<SingleAppView> {
  late final TextEditingController appNameController;
  late final TextEditingController baseUrlController;
  ImageProvider? imageProvider;

  @override
  void initState() {
    super.initState();
    appNameController = TextEditingController(text: widget.config?.appName);
    baseUrlController = TextEditingController(text: widget.config?.baseUrl?.toString());
    imageProvider = AppOverviewPage.getAppIcon(widget.config);
  }

  @override
  void didUpdateWidget(covariant SingleAppView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      if (widget.config?.appName != null) appNameController.text = widget.config!.appName!;
      if (widget.config?.baseUrl != null) baseUrlController.text = widget.config!.baseUrl!.toString();
      imageProvider = AppOverviewPage.getAppIcon(widget.config);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 16;

    return SingleChildScrollView(
      child: Theme(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: imageProvider != null ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (imageProvider != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Center(
                      child: SizedBox(
                        height: 150,
                        child: AppImage(
                          image: imageProvider,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Material(
                    type: MaterialType.card,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: appNameController,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          icon: const FaIcon(FontAwesomeIcons.cubes),
                          labelText: "${FlutterUI.translate("App Name")}*",
                          border: InputBorder.none,
                          suffixIcon: appNameController.text.isNotEmpty
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
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: baseUrlController,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (value) => _start(),
                        decoration: InputDecoration(
                          icon: const FaIcon(FontAwesomeIcons.globe),
                          labelText: "${FlutterUI.translate("URL")}*",
                          border: InputBorder.none,
                          hintText: "http://host:port/services/mobile",
                          suffixIcon: baseUrlController.text.isNotEmpty
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: Material(
                        type: MaterialType.button,
                        elevation: 6.0,
                        borderRadius: BorderRadius.circular(borderRadius),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(borderRadius),
                          onTap: () => _start(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  FlutterUI.translate("Open"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                FaIcon(
                                  FontAwesomeIcons.arrowRight,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Future<void> _start() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (appNameController.text.isNotEmpty && baseUrlController.text.isNotEmpty) {
      try {
        // Validate format
        var uri = Uri.parse(baseUrlController.text.trim());

        var newConfig = ServerConfig(
          appName: ParseUtil.ensureNullOnEmpty(appNameController.text),
          baseUrl: ParseUtil.appendJVxUrlSuffix(uri),
        );

        widget.onStart.call(newConfig);
      } catch (e, stack) {
        FlutterUI.log.i("User entered invalid URL", e, stack);
        await AppOverviewPage.showInvalidURLDialog(context, e);
      }
    } else {
      await AppOverviewPage.showRequiredFieldsDialog(context);
    }
  }
}
