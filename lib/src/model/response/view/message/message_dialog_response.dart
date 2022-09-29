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
    required super.originalRequest,
  });

  MessageDialogResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : componentId = pJson[ApiObjectProperty.componentId],
        closable = pJson[ApiObjectProperty.closable] ?? true,
        buttonType = pJson[ApiObjectProperty.buttonType],
        okComponentId = pJson[ApiObjectProperty.okComponentId],
        notOkComponentId = pJson[ApiObjectProperty.notOkComponentId],
        cancelComponentId = pJson[ApiObjectProperty.cancelComponentId],
        okText = pJson[ApiObjectProperty.okText],
        notOkText = pJson[ApiObjectProperty.notOkText],
        cancelText = pJson[ApiObjectProperty.cancelText],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
