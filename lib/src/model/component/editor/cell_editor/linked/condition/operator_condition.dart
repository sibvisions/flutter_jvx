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

import 'package:collection/collection.dart';

import '../../../../../../service/api/shared/api_object_property.dart';
import 'base_condition.dart';

class OperatorCondition extends BaseCondition {
  final List<BaseCondition>? conditions;
  final BaseCondition? condition;

  OperatorCondition(super.type, this.conditions, this.condition);

  OperatorCondition.fromJson(super.json)
      : conditions = (json[ApiObjectProperty.conditions] as List<dynamic>?)
            ?.map((e) => BaseCondition.parseCondition(e))
            .whereNotNull()
            .toList(),
        condition = BaseCondition.parseCondition(json[ApiObjectProperty.condition]),
        super.fromJson();
}
