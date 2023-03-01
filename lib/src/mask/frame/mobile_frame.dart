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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../drawer/drawer_menu.dart';
import '../state/loading_bar.dart';
import 'frame.dart';

class MobileFrame extends Frame {
  const MobileFrame({
    super.key,
    required super.builder,
    required super.isOffline,
  });

  @override
  MobileFrameState createState() => MobileFrameState();
}

class MobileFrameState extends FrameState {
  @override
  List<Widget> getActions() {
    return [
      ...super.getActions(),
      Builder(
        builder: (context) => IconButton(
          icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    ];
  }

  @override
  PreferredSizeWidget getAppBar({
    Widget? leading,
    Widget? title,
    double? titleSpacing,
    Color? backgroundColor,
    List<Widget>? actions,
  }) {
    return AppBar(
      leading: leading,
      title: title,
      centerTitle: false,
      titleSpacing: titleSpacing,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: 0,
    );
  }

  @override
  Widget? getEndDrawer(BuildContext context) {
    return Builder(
      builder: (context) => DrawerMenu(
        onSettingsPressed: () => widget.openSettings(context),
        onChangePasswordPressed: widget.changePassword,
        onLogoutPressed: widget.logout,
        onAppChange: widget.changeApp,
      ),
    );
  }

  @override
  Widget wrapBody(Widget body) {
    return LoadingBar.wrapLoadingBar(body);
  }
}
