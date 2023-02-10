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
import 'package:flutter_treeview/flutter_treeview.dart';

import '../../model/component/fl_component_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlTreeWidget<T extends FlTreeModel> extends FlStatelessWidget<T> {
  final TreeViewController controller;

  final Function(String, bool)? onExpansionChanged;

  final Function(String)? onNodeTap;

  final Function(String)? onNodeDoubleTap;

  const FlTreeWidget({
    super.key,
    required super.model,
    required this.controller,
    this.onNodeTap,
    this.onNodeDoubleTap,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(5.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
        color: Theme.of(context).colorScheme.background,
      ),
      child: ClipRRect(
        // The clip rect is there to stop the rendering of the children.
        // Otherwise the children would clip the border of the parent container.
        borderRadius: borderRadius,
        child: TreeView(
          controller: controller,
          onNodeTap: onNodeTap,
          onNodeDoubleTap: onNodeDoubleTap,
          onExpansionChanged: onExpansionChanged,
          allowParentSelect: true,
          supportParentDoubleTap: true,
        ),
      ),
    );
  }
}
