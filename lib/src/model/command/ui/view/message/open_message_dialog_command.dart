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

import 'package:flutter/cupertino.dart';

import 'message_view_command.dart';

/// This command will open a popup containing the provided message
class OpenMessageDialogCommand extends MessageViewCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The value notifier for changes
  late ValueNotifier<OpenMessageDialogCommand> current;

  /// Name of the message screen used for closing the message
  final String componentName;

  /// Name of the ok button
  final String? okComponentName;

  /// Name of the not ok button
  final String? notOkComponentName;

  /// Name of the cancel button
  final String? cancelComponentName;

  /// Text of the ok button
  final String? okText;

  /// Text of the not ok button
  final String? notOkText;

  /// Text of the cancel button
  final String? cancelText;

  /// Input field label
  final String? inputLabel;

  /// The data provider name
  final String? dataProvider;

  /// The column name of dataProvider
  final String? columnName;

  /// If the dialog should be closeable
  final bool closable;

  /// Types of button to be displayed
  final int buttonType;

  /// Types of icon to be displayed
  final int iconType;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OpenMessageDialogCommand({
    super.title,
    super.message,
    required this.componentName,
    required this.closable,
    required this.buttonType,
    required this.iconType,
    required this.okComponentName,
    required this.notOkComponentName,
    required this.cancelComponentName,
    this.okText,
    this.notOkText,
    this.cancelText,
    this.dataProvider,
    this.columnName,
    this.inputLabel,
    required super.reason,
  }) {
    current = ValueNotifier<OpenMessageDialogCommand>(this);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "OpenMessageDialogCommand{componentName: $componentName, "
           "closable: $closable, buttonType: $buttonType, "
           "iconType: $iconType, okComponentName: $okComponentName, "
           "notOkComponentName: $notOkComponentName, cancelComponentName: $cancelComponentName, "
           "okText: $okText, notOkText: $notOkText, cancelText: $cancelText, "
           "dataProvider: $dataProvider, columnName: $columnName,"
           "inputLabel: $inputLabel, ${super.toString()}";
  }

  void apply(OpenMessageDialogCommand command) {
    current.value = command;
  }

}
