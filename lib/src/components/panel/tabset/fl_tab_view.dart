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

import 'package:flutter/widgets.dart';

class FlTabView extends StatefulWidget {
  final Widget child;

  const FlTabView({super.key, required this.child});

  @override
  FlTabViewState createState() => FlTabViewState();
}

class FlTabViewState extends State<FlTabView> with AutomaticKeepAliveClientMixin {
  bool _keepAlive = true;

  @override
  bool get wantKeepAlive => _keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    try {
      BuildContext? childContext = (widget.child.key as GlobalKey).currentContext;
      if (childContext != null) {
        Widget? parentWidget = childContext.findAncestorWidgetOfExactType<FlTabView>();
        if (parentWidget != widget) {
          _keepAlive = false;
          updateKeepAlive();
        }
      }
    } catch (_) {
      _keepAlive = false;
    }

    if (_keepAlive) {
      return widget.child;
    } else {
      return Container();
    }
  }
}
