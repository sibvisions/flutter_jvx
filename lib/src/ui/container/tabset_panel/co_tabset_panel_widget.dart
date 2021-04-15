import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../flutterclient.dart';
import '../../widgets/custom/custom_icon.dart';
import '../co_container_widget.dart';
import 'models/tabset_panel_component_model.dart';

class CoTabsetPanelWidget extends CoContainerWidget {
  CoTabsetPanelWidget({required TabsetPanelComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoTabsetPanelWidgetState();
}

class CoTabsetPanelWidgetState extends CoContainerWidgetState
    with TickerProviderStateMixin {
  double iconSize = 15;

  late TabController tabController;

  List<Tab> createTabs() {
    final TabsetPanelComponentModel componentModel =
        widget.componentModel as TabsetPanelComponentModel;

    List<Tab> tablist = <Tab>[];
    componentModel.isEnabled = <bool>[];
    componentModel.isClosable = <bool>[];

    componentModel.components.forEach((comp) {
      List splittedConstr = comp.componentModel.constraints.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      String text = splittedConstr[2] ?? '';
      String img = splittedConstr.length >= 4 ? splittedConstr[3] : '';

      componentModel.isEnabled.add(enabled);
      componentModel.isClosable.add(closable);

      Tab tab = new Tab(
        child: Column(
          children: [
            img.isNotEmpty
                ? CustomIcon(
                    image: img.split(',')[0],
                    prefferedSize: Size(iconSize, iconSize),
                    color: Colors.grey.shade700,
                  )
                : Container(height: iconSize),
            SizedBox(
              height: 5,
            ),
            if (!closable)
              AutoSizeText(
                text,
                style: !enabled
                    ? TextStyle(color: Colors.grey)
                    : TextStyle(color: Colors.black),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    text,
                    style: !enabled
                        ? TextStyle(color: Colors.grey)
                        : TextStyle(color: Colors.black),
                  ),
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
    this.tabController = TabController(
        initialIndex: index,
        length:
            (widget.componentModel as TabsetPanelComponentModel).tabs.length,
        vsync: this)
      ..addListener(_handleTabAnimation);
  }

  void _handleTabAnimation() {
    final TabsetPanelComponentModel componentModel =
        widget.componentModel as TabsetPanelComponentModel;

    if (!this.tabController.indexIsChanging) {
      if (componentModel.pendingDeletes.isNotEmpty) {
        setState(() {
          for (int index in componentModel.pendingDeletes) {
            componentModel.components.removeAt(index);

            sl<ApiCubit>().tabClose(TabCloseRequest(
                componentId: componentModel.name,
                clientId: componentModel.appState.applicationMetaData!.clientId,
                index: index));
          }
          _initTabController(0);
          componentModel.pendingDeletes.clear();
        });
      }

      if (!componentModel.isEnabled[this.tabController.index]) {
        this.tabController.animateTo(this.tabController.previousIndex);
      } else {
        sl<ApiCubit>().tabSelect(TabSelectRequest(
            componentId: componentModel.name,
            index: tabController.index,
            clientId: componentModel.appState.applicationMetaData!.clientId));
      }
    }
  }

  void closeTab(int index) {
    final TabsetPanelComponentModel componentModel =
        widget.componentModel as TabsetPanelComponentModel;

    if (index > 0) {
      setState(() {
        componentModel.pendingDeletes.add(index);
        this.tabController.animateTo(0);
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
    this.tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int _idx =
        (widget.componentModel as TabsetPanelComponentModel).selectedIndex;
    if (_idx != this.tabController.index) {
      tabController.animateTo(_idx >= 0 ? _idx : 0);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: TabBar(
              isScrollable: false,
              controller: this.tabController,
              tabs: (widget.componentModel as TabsetPanelComponentModel)
                  .tabs
                  .map((tab) => tab)
                  .toList()),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return TabBarView(
                controller: this.tabController,
                children: (widget.componentModel as TabsetPanelComponentModel)
                    .getTabsetComponents(constraints));
          }),
        );
      },
    );
  }
}
