/*
 * Copyright 2022-2023 SIB Visions GmbH
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
import 'package:url_launcher/url_launcher.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/response/login_view_response.dart';
import '../../../../util/jvx_webview.dart';
import '../../../../util/loading_gauge.dart';
import 'mfa_card.dart';

class MFAUrlCard extends StatefulWidget {
  final int? timeout;
  final bool? timeoutReset;
  final Link? link;

  const MFAUrlCard({
    super.key,
    this.timeout,
    this.timeoutReset,
    this.link,
  });

  @override
  State<MFAUrlCard> createState() => _MFAUrlCardState();
}

class _MFAUrlCardState extends State<MFAUrlCard> {
  Link? link;

  @override
  void initState() {
    super.initState();
    link = widget.link;
  }

  @override
  void didUpdateWidget(covariant MFAUrlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.link != null) {
      link = widget.link!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MFACard(
      child: Column(
        children: [
          Column(
            children: [
              const Text("URL:"),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: link?.url != null
                    ? () {
                        Uri uri = Uri.parse(link!.url!);
                        if (kIsWeb) {
                          launchUrl(
                            uri,
                            webOnlyWindowName: FlutterUI.translate("Verification"),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(FlutterUI.translate("Verification")),
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                elevation: 0,
                              ),
                              body: JVxWebView(
                                initialUrl: uri,
                              ),
                            ),
                            barrierDismissible: false,
                          );
                        }
                      }
                    : null,
                child: Text(
                  link?.url ?? "-",
                  style: const TextStyle(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LoadingGauge(
                timeout: widget.timeout,
                timeoutReset: widget.timeoutReset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
