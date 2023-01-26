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

class _MFAUrlCardState extends State<MFAUrlCard> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late int timeout;
  late Link link;

  @override
  void initState() {
    super.initState();
    timeout = widget.timeout!;
    link = widget.link!;
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: timeout),
    )..addListener(() => setState(() {}));
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant MFAUrlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeoutReset ?? false) {
      controller.reset();
      controller.forward();
    }
    if (widget.timeout != null) {
      controller.duration = Duration(milliseconds: widget.timeout!);
    }
    if (widget.link != null) {
      link = widget.link!;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? timeLeft = controller.lastElapsedDuration != null
        ? ((timeout - controller.lastElapsedDuration!.inMilliseconds) / 1000)
        : null;
    return MFACard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Text("URL:"),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Uri uri = Uri.parse(link.url!);
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
                  },
                  child: Text(
                    link.url ?? "-",
                    style: const TextStyle(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints.tight(const Size.square(100)),
                      child: CircularProgressIndicator(
                        value: 1.0 - controller.value,
                        backgroundColor: Colors.grey,
                        strokeWidth: 20.0,
                      ),
                    ),
                    Text(
                      "${timeLeft?.toStringAsFixed(0) ?? "-"}s",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
