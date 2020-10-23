import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/tabset_panel/custom_tabset.dart';

import '../../../logic/bloc/api_bloc.dart';
import '../../../model/api/request/tab_close.dart';
import '../../../model/api/request/tab_select.dart';
import '../../../model/changed_component.dart';
import '../../../model/properties/component_properties.dart';
import '../../../ui/widgets/custom_icon.dart';
import '../../../utils/globals.dart' as globals;
import '../../component/component_widget.dart';
import '../co_container_widget.dart';
import '../container_component_model.dart';

class CoTabsetPanelWidget extends CoContainerWidget {
  CoTabsetPanelWidget({ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoTabsetPanelWidgetState();
}

class CoTabsetPanelWidgetState extends CoContainerWidgetState {
  bool eventTabClosed;
  bool eventTabActivated;
  bool eventTabMoved;
  int selectedIndex = 0;

  List<bool> _isEnabled = <bool>[];
  List<bool> _isClosable = <bool>[];

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    eventTabClosed =
        changedComponent.getProperty<bool>(ComponentProperty.EVENT_TAB_CLOSED);
    eventTabActivated = changedComponent
        .getProperty<bool>(ComponentProperty.EVENT_TAB_ACTIVATED);
    eventTabMoved =
        changedComponent.getProperty<bool>(ComponentProperty.EVENT_TAB_MOVED);
    int indx =
        changedComponent.getProperty<int>(ComponentProperty.SELECTED_INDEX);
    selectedIndex = indx != null && indx >= 0 ? indx : 0;
  }

  void onTap(int index) {
    setState(() {
      this.selectedIndex = index;
    });
    BlocProvider.of<ApiBloc>(context).dispatch(TabSelect(
        clientId: globals.clientId,
        componentId: this.name,
        index: this.selectedIndex));
  }

  void onClose(int index) {
    if (eventTabClosed != null && eventTabClosed) {
      BlocProvider.of<ApiBloc>(context).dispatch(TabClose(
          clientId: globals.clientId, componentId: this.name, index: index));
    }

    setState(() {
      this.components.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: this.components.length,
      initialIndex: this.selectedIndex,
      child: CustomTabset(
          components: this.components,
          onTap: this.onTap,
          onClose: this.onClose,
          index: this.selectedIndex,
          isEnabled: this._isEnabled,
          isClosable: this._isClosable),
    );
  }
}
