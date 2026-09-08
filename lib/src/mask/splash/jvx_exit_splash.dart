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

import 'package:material_ui/material_ui.dart';

import '../../flutter_ui.dart';
import '../../util/jvx_colors.dart';

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
              color: Colors.white54,
              borderRadius: BorderRadius.all(Radius.circular(18)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator.adaptive(backgroundColor: JVxColors.LIGHTER_BLACK),
                      const SizedBox(height: 15),
                      Text(
                        FlutterUI.translateLocal("Exiting"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: JVxColors.LIGHTER_BLACK),
                      ),
                    ],
                )
              )
            ),
          ),
      ],
    );
  }
}
