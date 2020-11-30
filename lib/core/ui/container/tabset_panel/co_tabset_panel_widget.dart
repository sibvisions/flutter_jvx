import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/ui/container/tabset_panel/models/tabset_panel_component_model.dart';

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
  List<Tab> createTabs() {
    final TabsetPanelComponentModel componentModel =
        widget.componentModel as TabsetPanelComponentModel;

    List<Tab> tablist = <Tab>[];
    componentModel.isEnabled = <bool>[];
    componentModel.isClosable = <bool>[];

    componentModel.components.forEach((comp) {
      List splittedConstr = comp.componentModel.constraints?.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      String text = splittedConstr[2];
      String img = splittedConstr.length >= 4 ? splittedConstr[3] : '';

      componentModel.isEnabled.add(enabled);
      componentModel.isClosable.add(closable);

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
                          closeTab(componentModel.components.indexOf(comp));
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
    (widget.componentModel as TabsetPanelComponentModel).tabs = createTabs();
    (widget.componentModel as TabsetPanelComponentModel).tabController =
        TabController(
            initialIndex: index,
            length: (widget.componentModel as TabsetPanelComponentModel)
                .tabs
                .length,
            vsync: this)
          ..addListener(_handleTabAnimation);
  }

  void _handleTabAnimation() {
    final TabsetPanelComponentModel componentModel =
        widget.componentModel as TabsetPanelComponentModel;

    if (!componentModel.tabController.indexIsChanging) {
      if (componentModel.pendingDeletes.isNotEmpty) {
        setState(() {
          for (int index in componentModel.pendingDeletes) {
            componentModel.components.removeAt(index);
            BlocProvider.of<ApiBloc>(context).add(TabClose(
                clientId: componentModel.appState.clientId,
                componentId: widget.componentModel.name,
                index: index));
          }
          _initTabController(0);
          componentModel.pendingDeletes.clear();
        });
      }

      if (!componentModel.isEnabled[componentModel.tabController.index]) {
        componentModel.tabController
            .animateTo(componentModel.tabController.previousIndex);
      } else {
        BlocProvider.of<ApiBloc>(context).add(TabSelect(
            clientId: componentModel.appState.clientId,
            componentId: widget.componentModel.name,
            index: componentModel.tabController.index));
      }
    }
  }

  void closeTab(int index) {
    final TabsetPanelComponentModel componentModel = widget.componentModel;

    if (index > 0) {
      setState(() {
        componentModel.pendingDeletes.add(index);
        componentModel.tabController.animateTo(0);
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
    (widget.componentModel as TabsetPanelComponentModel)
        .tabController
        .dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
          isScrollable: true,
          controller: (widget.componentModel as TabsetPanelComponentModel)
              .tabController,
          tabs: (widget.componentModel as TabsetPanelComponentModel)
              .tabs
              .map((tab) => tab)
              .toList()),
      body: TabBarView(
          controller: (widget.componentModel as TabsetPanelComponentModel)
              .tabController,
          children:
              (widget.componentModel as TabsetPanelComponentModel).components),
    );
  }
}
