import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../../../models/api/request/tab_close.dart';
import '../../../models/api/request/tab_select.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../widgets/custom/custom_icon.dart';
import '../co_container_widget.dart';
import '../container_component_model.dart';

class CoTabsetPanelWidget extends CoContainerWidget {
  CoTabsetPanelWidget({ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoTabsetPanelWidgetState();
}

class CoTabsetPanelWidgetState extends CoContainerWidgetState
    with TickerProviderStateMixin {
  bool eventTabClosed;
  bool eventTabActivated;
  bool eventTabMoved;

  List<bool> _isEnabled = <bool>[];
  List<bool> _isClosable = <bool>[];

  TabController tabController;
  List<Tab> tabs = <Tab>[];
  List<int> pendingDeletes = <int>[];

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
    setState(() {
      tabController.animateTo(indx != null && indx >= 0 ? indx : 0);
    });
  }

  List<Tab> createTabs() {
    List<Tab> tablist = <Tab>[];
    _isEnabled = <bool>[];
    _isClosable = <bool>[];

    components.forEach((comp) {
      List splittedConstr = comp.componentModel.constraints?.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      String text = splittedConstr[2];
      String img = splittedConstr.length >= 4 ? splittedConstr[3] : '';

      _isEnabled.add(enabled);
      _isClosable.add(closable);

      double iconSize = 15;

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
                          closeTab(components.indexOf(comp));
                        },
                      ),
                    ],
                  ),
          ],
        ),
      );
      tablist.add(tab);
    });

    return tablist;
  }

  void _initTabController(int index) {
    tabs = createTabs();
    tabController =
        TabController(initialIndex: index, length: tabs.length, vsync: this)
          ..addListener(_handleTabAnimation);
  }

  void _handleTabAnimation() {
    if (!tabController.indexIsChanging) {
      if (pendingDeletes.isNotEmpty) {
        setState(() {
          for (int index in pendingDeletes) {
            this.components.removeAt(index);
            BlocProvider.of<ApiBloc>(context).add(TabClose(
                clientId: this.appState.clientId,
                componentId: this.name,
                index: index));
          }
          _initTabController(0);
          pendingDeletes.clear();
        });
      }

      if (!_isEnabled[tabController.index]) {
        tabController.animateTo(tabController.previousIndex);
      } else {
        BlocProvider.of<ApiBloc>(context).add(TabSelect(
            clientId: this.appState.clientId,
            componentId: this.name,
            index: tabController.index));
      }
    }
  }

  void closeTab(int index) {
    if (index > 0) {
      setState(() {
        pendingDeletes.add(index);
        tabController.animateTo(0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initTabController(0);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
          isScrollable: true,
          controller: tabController,
          tabs: tabs.map((tab) => tab).toList()),
      body: TabBarView(controller: tabController, children: this.components),
    );
  }
}
