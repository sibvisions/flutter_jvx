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

part 'list_space_builder.g.dart';

//dart run build_runner build --delete-conflicting-outputs

@jsonWidget
abstract class _ListSpaceBuilder extends JsonWidgetBuilder {
  const _ListSpaceBuilder({
    required super.args,
  });

  @override
  ListSpace buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  });
}

class ListSpace extends StatelessWidget {
  final JsonWidgetData data;

  final List<dynamic>? notEmptyColumnNames;
  final String? text;
  final double? width;
  final double? height;

  const ListSpace({
    @JsonBuildArg() required this.data,
    super.key,
    this.notEmptyColumnNames,
    this.text,
    this.width,
    this.height
  });

  @override
  Widget build(BuildContext context) {
    JsonWidgetFunction? func = data.jsonWidgetRegistry.getFunction("hasValue");

    if (func != null) {
      dynamic result = func(args: notEmptyColumnNames, registry: data.jsonWidgetRegistry);

      if (result is bool) {
        if (result) {
          if (width != null || height != null) {
            return SizedBox(width: width, height: height);
          }
          else if (text != null) {
            return Text(text!);
          }
        }
      }
    }

    return Container();
  }
}
