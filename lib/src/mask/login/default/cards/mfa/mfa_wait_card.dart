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

import 'package:flutter/material.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../util/loading_gauge.dart';
import '../mfa_card.dart';

class MFAWaitCard extends StatefulWidget {
  final int? timeout;
  final bool? timeoutReset;
  final String? confirmationCode;

  const MFAWaitCard({
    super.key,
    this.timeout,
    this.timeoutReset,
    this.confirmationCode,
  });

  @override
  State<MFAWaitCard> createState() => _MFAWaitCardState();
}

class _MFAWaitCardState extends State<MFAWaitCard> {
  String? confirmationCode;

  @override
  void initState() {
    super.initState();
    confirmationCode = widget.confirmationCode;
  }

  @override
  void didUpdateWidget(covariant MFAWaitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.confirmationCode != null) {
      confirmationCode = widget.confirmationCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MFACard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          LoadingGauge(
            timeout: widget.timeout,
            timeoutReset: widget.timeoutReset,
          ),
          Column(
            children: [
              Text(FlutterUI.translate("Matching code")),
              Text(
                confirmationCode ?? "-",
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
