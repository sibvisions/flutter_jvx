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
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:rxdart/rxdart.dart';

import '../../../flutter_jvx.dart';
import '../../components/components_factory.dart';
import '../../model/component/fl_component_model.dart';
import '../frame_dialog.dart';
import 'work_screen.dart';

/// Screen used to show workScreens either custom or from the server,
/// will send a [DeviceStatusCommand] on open to account for
/// custom header/footer
class Content extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the content to show.
  final String name;

  /// If this content is in a dialog.
  final bool isDialog;

  const Content({
    super.key,
    required this.name,
    this.isDialog = false,
  });

  @override
  ContentState createState() => ContentState();
}

class ContentState extends State<Content> {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  late FlPanelModel model;

  bool sentSize = false;

  @override
  void initState() {
    super.initState();
    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) => _setScreenSize(size));

    model = IStorageService().getComponentByName(pComponentName: widget.name) as FlPanelModel;
  }

  @override
  void dispose() {
    subject.close();
    IUiService().disposeSubscriptions(pSubscriber: this);
    IUiService().closeContent(model.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appStyle = AppStyle.of(context).applicationStyle;
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
    String? backgroundImageString = appStyle['desktop.icon'];

    Widget content = KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) => LayoutBuilder(
        builder: (context, constraints) {
          final viewInsets = EdgeInsets.fromWindowPadding(
            WidgetsBinding.instance.window.viewInsets,
            WidgetsBinding.instance.window.devicePixelRatio,
          );

          final viewPadding = EdgeInsets.fromWindowPadding(
            WidgetsBinding.instance.window.viewPadding,
            WidgetsBinding.instance.window.devicePixelRatio,
          );

          double screenHeight = constraints.maxHeight;

          if (isKeyboardVisible) {
            screenHeight += viewInsets.bottom;
            screenHeight -= viewPadding.bottom;
          }

          Widget screenWidget = ComponentsFactory.buildWidget(model);

          Size size = Size(constraints.maxWidth, screenHeight);
          if (!sentSize) {
            _setScreenSize(size);
            sentSize = true;
          } else {
            subject.add(size);
          }

          return SingleChildScrollView(
            physics: isKeyboardVisible ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                SizedBox(
                  height: screenHeight,
                  width: constraints.maxWidth,
                  child: WorkScreen.buildBackground(backgroundColor, backgroundImageString),
                ),
                screenWidget
              ],
            ),
          );
        },
      ),
    );

    if (widget.isDialog) {
      return content;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(model.contentTitle ?? model.name),
      ),
      body: content,
    );
  }

  void _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: model.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }
}

class ContentDialog extends JVxDialog {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the content to show.
  final String name;

  final PageStorageBucket bucket = PageStorageBucket();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ContentDialog({
    super.key,
    required this.name,
    super.dismissible = true,
    super.isModal = true,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Widget child = PageStorage(
      bucket: bucket,
      child: Dialog(
        child: Content(
          name: name,
          isDialog: true,
        ),
      ),
    );

    if (!isModal) {
      return child;
    }

    return Stack(
      children: [
        Opacity(
          opacity: 0.7,
          child: ModalBarrier(
            dismissible: dismissible,
            color: Colors.black54,
            onDismiss: () {
              IUiService().closeContent(name);
            },
          ),
        ),
        child,
      ],
    );
  }
}
