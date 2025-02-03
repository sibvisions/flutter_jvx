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
import 'work_screen_page.dart';

/// Screen used to show workScreens either custom or from the server,
/// will send a [DeviceStatusCommand] on open to account for
/// custom header/footer
class Content extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String ROUTE_SETTINGS_PREFIX = "content_";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of the content to show.
  final FlPanelModel model;

  const Content({
    super.key,
    required this.model,
  });

  @override
  ContentState createState() => ContentState();
}

class ContentState extends State<Content> {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  bool sentSize = false;

  @override
  void initState() {
    super.initState();
    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) => _setScreenSize(size));
  }

  @override
  void dispose() {
    subject.close();
    IUiService().closeContent(widget.model.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStyle appStyle = AppStyle.of(context);
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle.style(context, 'desktop.color'));
    String? backgroundImageString = appStyle.style(context, 'desktop.icon');

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) => LayoutBuilder(
        builder: (context, constraints) {
          final viewInsets = EdgeInsets.fromViewPadding(
            View.of(context).viewInsets,
            View.of(context).devicePixelRatio,
          );

          final viewPadding = EdgeInsets.fromViewPadding(
            View.of(context).viewPadding,
            View.of(context).devicePixelRatio,
          );

          double screenHeight = constraints.maxHeight;

          if (isKeyboardVisible) {
            screenHeight += viewInsets.bottom;
            screenHeight -= viewPadding.bottom;
          }

          Widget screenWidget = ComponentsFactory.buildWidget(widget.model);

          Size size = Size(constraints.maxWidth, screenHeight);

          if (!sentSize) {
            _setScreenSize(size);
            sentSize = true;
          } else {
            subject.add(size);
          }

          return Listener(onPointerDown: (event) {
                            List<GlobalSubscription> copy = FlutterUI.globalSubscriptions();

                            for (int i = 0; i < copy.length; i++) {
                              copy[i].onTap?.call(event);
                            }
                          },
                          child: SingleChildScrollView(
                            physics: isKeyboardVisible ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: screenHeight,
                                  width: constraints.maxWidth,
                                  child: WorkScreenPage.buildBackground(backgroundColor, backgroundImageString),
                                ),
                                screenWidget
                              ],
                            ),
                          )
          );
        },
      ),
    );
  }

  void _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: widget.model.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await ICommandService().sendCommand(e)));
  }
}

class ContentDialog extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of the content to show.
  final FlPanelModel model;

  final bool dismissible;

  final bool isModal;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ContentDialog({
    super.key,
    required this.model,
    this.dismissible = true,
    this.isModal = true,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Widget child = Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            centerTitle: true,
            title: Text(model.contentTitle ?? model.name),
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: Content(
              model: model,
            ),
          ),
        ],
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
              IUiService().closeContent(model.name);
            },
          ),
        ),
        child,
      ],
    );
  }
}

class ContentBottomSheet extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of the content to show.
  final FlPanelModel model;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ContentBottomSheet({
    super.key,
    required this.model,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {

    Widget content = Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(model.contentTitle ?? model.name),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            // This is a hack to prevent the bottom sheet from scrolling
            // when the content is scrollable.
            return true;
          },
          child: Content(
            model: model,
          ),
        ),
      ),
    );

    //should be possible to use a custom height
    if (model.preferredSize != null) {
      content = SizedBox(
        height: model.preferredSize!.height,
        child: content);
    }

    return content;
  }
}
