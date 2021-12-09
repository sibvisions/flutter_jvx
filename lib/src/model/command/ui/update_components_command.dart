import 'ui_command.dart';
import '../../component/fl_component_model.dart';

/// Command to update components.
class UpdateComponentsCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The affected component models.
  final List<FlComponentModel> affectedComponents;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Initialization
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UpdateComponentsCommand({
    required this.affectedComponents,
    required String reason
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Overridden methods
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  @override
  String get logString {
    String allAffectedComponentIds = "[";

    for (FlComponentModel element in affectedComponents) 
    {
      allAffectedComponentIds += " " + element.id + ";";
    }

    return "UpdateComponentsCommand Reason: $reason | Affected IDs: " + allAffectedComponentIds + "]";
  }
}