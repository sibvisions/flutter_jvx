import '../../../../../mixin/services.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/command/ui/route_to_work_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/model_factory.dart';
import '../../../../model/request/api_open_screen_request.dart';
import '../../../../model/response/generic_screen_view_response.dart';
import '../api_object_property.dart';
import '../i_response_processor.dart';

/// Processes [GenericScreenViewResponse], will separate (and parse) new and changed components, can also open screens
/// based on the 'update' property of the request.
///
/// Possible return Commands : [SaveComponentsCommand], [RouteCommand]
class GenericScreenViewProcessor with ConfigServiceMixin implements IResponseProcessor<GenericScreenViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required GenericScreenViewResponse pResponse}) {
    List<BaseCommand> commands = [];
    GenericScreenViewResponse screenGenericResponse = pResponse;

    // Handle New & Changed Components
    // Get new full components
    List<dynamic>? changedComponents = pResponse.changedComponents;
    if (changedComponents != null) {
      List<FlComponentModel>? componentsToSave = _getNewComponents(changedComponents);

      // Get changed Components
      List<dynamic>? updatedComponent = _getChangedComponents(changedComponents);

      if (componentsToSave != null || updatedComponent != null) {
        if (screenGenericResponse.originalRequest is ApiOpenScreenRequest) {
          ApiOpenScreenRequest originalRequest = screenGenericResponse.originalRequest as ApiOpenScreenRequest;
          componentsToSave
              ?.where(
                (element) => element.name == screenGenericResponse.screenName,
              )
              .forEach(
                (element) => element.screenLongName = originalRequest.screenLongName,
              );
        }

        SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand(
          reason: "Api received screen.generic response",
          componentsToSave: componentsToSave,
          updatedComponent: updatedComponent,
          screenName: screenGenericResponse.screenName,
        );
        commands.add(saveComponentsCommand);
      }
    }

    // Handle Screen Opening
    // if update == false => new screen that should be routed to
    if (!screenGenericResponse.update && !getConfigService().isOffline()) {
      RouteToWorkCommand workCommand = RouteToWorkCommand(
        screenName: screenGenericResponse.screenName,
        reason: "Server sent screen.generic response with update = 'false'",
      );
      commands.add(workCommand);
    }
    return commands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns List of all changed components json, or null if none are found.
  List<dynamic>? _getChangedComponents(List<dynamic> pChangedComponents) {
    List<dynamic> changedComponents = [];

    for (dynamic component in pChangedComponents) {
      if (component[ApiObjectProperty.className] == null) {
        changedComponents.add(component);
      }
    }

    if (changedComponents.isNotEmpty) {
      return changedComponents;
    }
    return null;
  }

  /// Returns List of new [FlComponentModel] models parsed from json, only components with a [ApiObjectProperty.className] are considered new, if none are found will return null.
  List<FlComponentModel>? _getNewComponents(List<dynamic> changedComponents) {
    List<FlComponentModel> models = [];
    for (dynamic changedComponent in changedComponents) {
      String? className = changedComponent[ApiObjectProperty.className];
      if (className != null) {
        FlComponentModel model = _parseFlComponentModel(changedComponent, className);
        models.add(model);
      }
    }
    if (models.isNotEmpty) {
      return models;
    }
    return null;
  }

  /// Parses json component into its appropriate [FlComponentModel], which is termite by its [ApiObjectProperty.className].
  FlComponentModel _parseFlComponentModel(dynamic pJson, String className) {
    FlComponentModel model = ModelFactory.buildModel(pJson, className);
    model.applyFromJson(pJson);
    return model;
  }
}
