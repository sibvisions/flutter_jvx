/* Copyright 2022 SIB Visions GmbH
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

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/component/dummy/fl_dummy_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlDummyWidget extends FlStatelessWidget<FlDummyModel> {
  const FlDummyWidget({super.key, required super.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDebugMode
          ? Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
          : Theme.of(context).backgroundColor,
      alignment: Alignment.bottomLeft,
      child: Text(
        "Dummy for ${model.id}",
        textAlign: TextAlign.end,
      ),
    );
  }
}
