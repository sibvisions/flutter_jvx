import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import 'package:jvx_flutterclient/logic/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/model/api/request/tab_close.dart';
import 'package:jvx_flutterclient/model/api/request/tab_select.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/utils/globals.dart' as globals;

class CoTabsetPanel extends CoContainer implements IContainer {
  bool eventTabClosed;
  bool eventTabActivated;
  bool eventTabMoved;
  int selectedIndex = 0;

  CoTabsetPanel(
      GlobalKey<State<StatefulWidget>> componentId, BuildContext context)
      : super(componentId, context);

  factory CoTabsetPanel.withCompContext(ComponentContext componentContext) {
    return CoTabsetPanel(componentContext.globalKey, componentContext.context);
  }

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

  @override
  Widget getWidget() {
    if (this.components.isNotEmpty) {
      return CustomTabSet(
        key: componentId,
        components: components,
        currentIndex: selectedIndex,
        onTabChanged: _onTabChanged,
        onTabClosed: _onTabClosed,
      );
    } else {
      return Container();
    }
  }
}

class CustomTabSet extends StatefulWidget {
  final List<IComponent> components;
  final int currentIndex;
  final Function(int index) onTabChanged;
  final Function(int index) onTabClosed;

  CustomTabSet({
    Key key,
    @required this.components,
    @required this.currentIndex,
    @required this.onTabChanged,
    @required this.onTabClosed,
  }) : super(key: key);

  @override
  _CustomTabSetState createState() => _CustomTabSetState();
}

class _CustomTabSetState extends State<CustomTabSet>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<bool> _isEnabled = <bool>[];
  List<bool> _isClosable = <bool>[];
  bool locked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.components.length,
      vsync: this,
      initialIndex: widget.currentIndex,
    );
    locked = true;
    _tabController.addListener(_onTap);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _onTap() {
    if (!_isEnabled[_tabController.index]) {
      int index = _tabController.previousIndex;
      setState(() {
        _tabController.index = index;
      });
    } else if (!locked && _isEnabled[_tabController.previousIndex]) {
      widget.onTabChanged(_tabController.index);
    }
    locked = false;
  }

  _onTabClosed() {
    if (!locked) widget.onTabClosed(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Flexible(
            flex: 2,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              tabs: _getTabs(widget.components),
              onTap: (index) => _onTap(),
            ),
          ),
          Flexible(
            flex: 10,
            child: TabBarView(
              controller: _tabController,
              children: _getChildren(widget.components),
            ),
          ),
        ],
      ),
    );
  }

  List<Tab> _getTabs(List<IComponent> components) {
    List<Tab> tablist = <Tab>[];
    _isEnabled = <bool>[];
    _isClosable = <bool>[];

    components.forEach((comp) {
      List splittedConstr = comp.constraints?.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      String text = splittedConstr[2];
      String img = splittedConstr.length >= 4 ? splittedConstr[3] : '';

      Tab tab = new Tab(
        child: !closable
            ? Text(
                text ?? '',
                style: !enabled ? TextStyle(color: Colors.grey) : null,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(text ?? '',
                          style:
                              !enabled ? TextStyle(color: Colors.grey) : null),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: GestureDetector(
                      child: Icon(Icons.clear),
                      onTap: _onTabClosed,
                    ),
                  ),
                ],
              ),
      );

      _isEnabled.add(enabled);
      _isClosable.add(closable);
      tablist.add(tab);
    });

    return tablist;
  }

  List<Widget> _getChildren(List<IComponent> components) {
    List<Widget> children = <Widget>[];

    components.forEach((comp) {
      children.add(comp.getWidget());
    });

    return children;
  }
}
