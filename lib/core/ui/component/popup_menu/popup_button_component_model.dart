import '../../../models/api/component/changed_component.dart';
import '../component_model.dart';
import 'co_popup_menu_widget.dart';

class PopupButtonComponentModel extends ComponentModel {
  CoPopupMenuWidget menu;

  PopupButtonComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);
}
