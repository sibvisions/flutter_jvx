/*
 * Copyright 2025 SIB Visions GmbH
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
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';

/// Small utility to measure a widget before actually putting it on screen.
///
/// NOTE: Use sparingly, since this takes a complete layout and sizing pass for the subtree you
/// want to measure.
///
/// Compare https://api.flutter.dev/flutter/widgets/BuildOwner-class.html
class MeasureUtil {

    /// Measures widget size without adding to renderer tree
    static Size measureWidget(Widget widget, [BoxConstraints constraints = const BoxConstraints()]) {
        final PipelineOwner pipelineOwner = PipelineOwner();
        final _MeasurementView rootView = pipelineOwner.rootNode = _MeasurementView(constraints);
        final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

        final RenderObjectToWidgetElement<RenderBox> element = RenderObjectToWidgetAdapter<RenderBox>(
            container: rootView,
            debugShortDescription: '[measureRoot]',
            child: widget,
        ).attachToRenderTree(buildOwner);

        try {
            rootView.scheduleInitialLayout();
            pipelineOwner.flushLayout();
            return rootView.size;
        } finally {
            // Clean up.
            element.update(RenderObjectToWidgetAdapter<RenderBox>(container: rootView));
            buildOwner.finalizeTree();
        }
    }

    /// Measures size of html content without adding to renderer tree
    static ({Size size, Html html}) measureHtml(BuildContext context, String html, [EdgeInsets? insets]) {
        Html htmlView = Html(data: html,
            shrinkWrap: true,
            style: {"body": Style(margin: Margins(left: Margin(insets != null ? insets.left : 0),
                top: Margin(insets != null ? insets.top : 0),
                bottom: Margin(insets != null ? insets.bottom : 0),
                right: Margin(insets != null ? insets.right : 0)))});

        TextDirection textDirection = Directionality.of(context);

        Widget w = MediaQuery(data: MediaQuery.of(context),
            child: Directionality(textDirection: textDirection,
                child: Container(child: htmlView)));

        return (size: measureWidget(w), html: htmlView);
    }
}

class _MeasurementView extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
    final BoxConstraints boxConstraints;
    _MeasurementView(this.boxConstraints);

    @override
    void performLayout() {
        assert(child != null);
        child!.layout(boxConstraints, parentUsesSize: true);
        size = child!.size;
    }

    @override
    void debugAssertDoesMeetConstraints() => true;
}
