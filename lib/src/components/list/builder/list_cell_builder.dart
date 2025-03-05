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
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

part 'list_cell_builder.g.dart';

//dart run build_runner build --delete-conflicting-outputs

@jsonWidget
abstract class _ListCellBuilder extends JsonWidgetBuilder {
  const _ListCellBuilder({
    required super.args,
  });

  @override
  ListCell buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  });
}

class ListCell extends StatelessWidget {
  final JsonWidgetData data;

  final dynamic wrappedWidget;
  final String? columnName;
  final String? prefix;
  final String? postfix;
  final bool useFormat;

  const ListCell({
    @JsonBuildArg() required this.data,
    super.key,
    this.columnName,
    this.useFormat = true,
    this.prefix,
    this.postfix,
    this.wrappedWidget
  });

  @override
  Widget build(BuildContext context) {

    if (wrappedWidget != null) {
      return wrappedWidget;
    }

    JsonWidgetFunction? func = data.jsonWidgetRegistry.getFunction("formatListCell");

    if (func != null) {
      dynamic result = func(args: [this], registry: data.jsonWidgetRegistry);

      if (result is Widget) {
        return result;
      }
    }

    return wrappedWidget ?? Container();
  }
}
