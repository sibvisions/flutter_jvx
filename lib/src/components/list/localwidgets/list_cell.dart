/*
 * Copyright 2026 SIB Visions GmbH
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

import '../../util/data_context.dart';
import '../fl_list_entry.dart';

class ListCell extends StatelessWidget {
  final String? columnName;
  final String? prefix;
  final String? postfix;
  final bool useFormat;
  final Widget? wrappedWidget;

  const ListCell({
    super.key,
    this.columnName,
    this.useFormat = true,
    this.prefix,
    this.postfix,
    this.wrappedWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (wrappedWidget != null) {
      return wrappedWidget!;
    }

    if (columnName != null) {
      DataContext? dc = DataContext.of(context);

      if (dc != null) {
        FlListEntry entry = dc.data;

        Widget? w = entry.formatListCell(this);

        if (w != null) {
          return w;
        }
      }
    }

    return Container();
  }
}