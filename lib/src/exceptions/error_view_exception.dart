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

import '../model/command/ui/view/message/open_server_error_dialog_command.dart';
import 'view_exception.dart';

class ErrorViewException extends ViewException {
  /// The original cause of this exception.
  final OpenServerErrorDialogCommand errorCommand;

  ErrorViewException(this.errorCommand, [super.message]);

  @override
  String toString() {
    String s = super.toString();
    return "${s.isNotEmpty ? "$s " : s}${errorCommand.message}";
  }
}
