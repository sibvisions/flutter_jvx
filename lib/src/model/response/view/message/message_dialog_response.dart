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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MessageDialogResponse({
    required super.title,
    required super.message,
    required this.componentId,
    required this.closable,
    required this.buttonType,
    required this.okComponentId,
    required this.notOkComponentId,
    required this.cancelComponentId,
    required super.name,
    required super.originalRequest,
  });

  MessageDialogResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : componentId = pJson[ApiObjectProperty.componentId],
        closable = pJson[ApiObjectProperty.closable],
        buttonType = pJson[ApiObjectProperty.buttonType],
        okComponentId = pJson[ApiObjectProperty.okComponentId],
        notOkComponentId = pJson[ApiObjectProperty.notOkComponentId],
        cancelComponentId = pJson[ApiObjectProperty.cancelComponentId],
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
