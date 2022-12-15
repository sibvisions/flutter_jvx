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

import 'package:flutter/widgets.dart';

import '../../../../../../model/command/base_command.dart';
import '../../../../../isolate/isolate_message.dart';

class SetScreenSizeMessage extends IsolateMessage<List<BaseCommand>> {
  final String componentId;

  final Size size;

  SetScreenSizeMessage({required this.size, required this.componentId});
}
