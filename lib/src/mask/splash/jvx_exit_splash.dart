/*
 * Copyright 2022 SIB Visions GmbH
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../flutter_ui.dart';

class JVxExitSplash extends StatelessWidget {
  final AsyncSnapshot? snapshot;

  const JVxExitSplash({
    super.key,
    this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: snapshot?.connectionState == ConnectionState.done ? Colors.black54 : null,
        ),
        if (snapshot?.connectionState == ConnectionState.done)
          Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(color: Colors.white, radius: 18),
                  const SizedBox(height: 15),
                  Text(
                    FlutterUI.translateLocal("Exiting..."),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
