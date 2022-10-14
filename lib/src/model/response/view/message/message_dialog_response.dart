import '../../../../service/api/shared/api_object_property.dart';
import 'message_view.dart';

class MessageDialogResponse extends MessageView {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the message screen used for closing the message
  final String componentId;

  /// If the dialog should be dismissible
  final bool closable;

  /// Types of button to be displayed
  final int buttonType;

  /// Name of the ok button
  final String? okComponentId;

  /// Name of the not ok button
  final String? notOkComponentId;

  /// Name of the cancel button
  final String? cancelComponentId;

  /// Text of the ok button
  final String? okText;

  /// Text of the not ok button
  final String? notOkText;

  /// Text of the cancel button
  final String? cancelText;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageDialogResponse({
    required super.title,
    super.message,
    required this.componentId,
    this.closable = true,
    required this.buttonType,
    required this.okComponentId,
    required this.notOkComponentId,
    required this.cancelComponentId,
    this.okText,
    this.notOkText,
    this.cancelText,
    required super.name,
  });

  MessageDialogResponse.fromJson(super.json)
      : componentId = json[ApiObjectProperty.componentId],
        closable = json[ApiObjectProperty.closable] ?? true,
        buttonType = json[ApiObjectProperty.buttonType],
        okComponentId = json[ApiObjectProperty.okComponentId],
        notOkComponentId = json[ApiObjectProperty.notOkComponentId],
        cancelComponentId = json[ApiObjectProperty.cancelComponentId],
        okText = json[ApiObjectProperty.okText],
        notOkText = json[ApiObjectProperty.notOkText],
        cancelText = json[ApiObjectProperty.cancelText],
        super.fromJson();
}
