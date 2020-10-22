import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/tab_close.dart';
import '../../model/api/request/tab_select.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/widgets/custom_icon.dart';
import '../../utils/globals.dart' as globals;
import '../component/component_widget.dart';
import 'co_container_widget.dart';
import 'container_component_model.dart';

class CoTabsetPanelWidget extends CoContainerWidget {
  CoTabsetPanelWidget({ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoTabsetPanelWidgetState();
}

class CoTabsetPanelWidgetState extends CoContainerWidgetState
    with SingleTickerProviderStateMixin {
  bool eventTabClosed;
  bool eventTabActivated;
  bool eventTabMoved;
  int selectedIndex = 0;

  List<bool> _isEnabled = <bool>[];
  List<bool> _isClosable = <bool>[];

  TabController tabController;

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

  _onTabChanged(int index) {
    if (!this._isEnabled[this.tabController.index]) {
      int index = this.tabController.previousIndex;
      setState(() {
        this.tabController.index = index;
      });
    }

    this.selectedIndex = index;
    BlocProvider.of<ApiBloc>(context).dispatch(TabSelect(
        clientId: globals.clientId, componentId: this.name, index: index));
  }

  _onTabClosed(int index) {
    if (eventTabClosed != null && eventTabClosed) {
      BlocProvider.of<ApiBloc>(context).dispatch(TabClose(
          clientId: globals.clientId, componentId: this.name, index: index));
    }
  }

  _getChildren(List<ComponentWidget> components) {
    List<Widget> children = <Widget>[];

    components.forEach((comp) {
      children.add(comp);
    });

    return children;
  }

  _getTabs(List<ComponentWidget> components) {
    List<Tab> tabs = <Tab>[];

    components.forEach((comp) {
      List splittedConstr = comp.componentModel.constraints?.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      String text = splittedConstr[2];
      String img = splittedConstr.length >= 4 ? splittedConstr[3] : '';

      double iconSize = 15;

      _isEnabled.add(enabled);
      _isClosable.add(closable);

      Tab tab = new Tab(
        child: Column(
          children: [
            img != null && img.isNotEmpty
                ? CustomIcon(
                    image: img,
                    size: Size(iconSize, iconSize),
                    color: Colors.grey.shade700,
                  )
                : Container(height: iconSize),
            SizedBox(
              height: 5,
            ),
            !closable
                ? Text(
                    text ?? '',
                    style: !enabled ? TextStyle(color: Colors.grey) : null,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(text ?? '',
                          style:
                              !enabled ? TextStyle(color: Colors.grey) : null),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.clear,
                          size: 20,
                        ),
                        onTap: () {
                          _onTabClosed(components.indexOf(comp));
                        },
                      ),
                    ],
                  ),
          ],
        ),
      );

      tabs.add(tab);
    });

    return tabs;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
        vsync: this,
        initialIndex: selectedIndex,
        length: this.components.length);
  }

  @override
  Widget build(BuildContext context) {
    if (this.components.isNotEmpty) {
      return Column(
        children: [
          Flexible(
            flex: 2,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              indicatorColor: Colors.black,
              tabs: _getTabs(this.components),
              onTap: (index) => _onTabChanged(index),
            ),
          ),
          Flexible(
            flex: 10,
            child: TabBarView(
              controller: tabController,
              children: _getChildren(this.components),
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}
