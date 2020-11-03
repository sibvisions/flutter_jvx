import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../jvx_flutterclient.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/tab_close.dart';
import '../../model/api/request/tab_select.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../utils/globals.dart' as globals;
import '../widgets/custom_icon.dart';

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
      return DefaultTabController(
        length: this.components.length,
        initialIndex: this.components.length > selectedIndex
            ? (selectedIndex == -1 ? 0 : selectedIndex)
            : 0,
        key: componentId,
        child: CustomTabSet(
          components: components,
          currentIndex: selectedIndex == -1 ? 0 : selectedIndex,
          onTabChanged: _onTabChanged,
          onTabClosed: _onTabClosed,
        ),
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

class _CustomTabSetState extends State<CustomTabSet> {
  List<bool> _isEnabled = <bool>[];
  List<bool> _isClosable = <bool>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onTap() {
    if (!_isEnabled[DefaultTabController.of(context).index]) {
      int index = DefaultTabController.of(context).previousIndex;
      setState(() {
        DefaultTabController.of(context).index = index;
      });
    } else if (_isEnabled[DefaultTabController.of(context).previousIndex]) {
      widget.onTabChanged(DefaultTabController.of(context).index);
    }
  }

  _onTabClosed(int index) {
    widget.onTabClosed(index);
  }

  @override
  Widget build(BuildContext context) {
    _getEnabledAndClosable(widget.components);
    if (_isEnabled.length > DefaultTabController.of(context).index &&
        !_isEnabled[DefaultTabController.of(context).index]) {
      setState(() {
        DefaultTabController.of(context).index = 0;
      });
    } else if (widget.currentIndex != DefaultTabController.of(context).index &&
        _isEnabled.length > widget.currentIndex &&
        _isEnabled[widget.currentIndex]) {
      setState(() {
        DefaultTabController.of(context).index = widget.currentIndex;
      });
    }

    return Container(
      child: Column(
        children: [
          Flexible(
            flex: 2,
            child: TabBar(
              isScrollable: true,
              indicatorColor: Colors.black,
              tabs: _getTabs(widget.components),
              onTap: (indx) => _onTap(),
            ),
          ),
          Flexible(
            flex: 10,
            child: TabBarView(
              children: _getChildren(widget.components),
            ),
          ),
        ],
      ),
    );
  }

  _getEnabledAndClosable(List<IComponent> components) {
    _isEnabled = <bool>[];
    _isClosable = <bool>[];

    components.forEach((comp) {
      List splittedConstr = comp.constraints?.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      _isEnabled.add(enabled);
      _isClosable.add(closable);
    });
  }

  List<Tab> _getTabs(List<IComponent> components) {
    List<Tab> tablist = <Tab>[];

    components.forEach((comp) {
      List splittedConstr = comp.constraints?.split(';');
      bool enabled = (splittedConstr[0]?.toLowerCase() == 'true');
      bool closable = (splittedConstr[1]?.toLowerCase() == 'true');
      String text = splittedConstr[2];
      String img = splittedConstr.length >= 4 ? splittedConstr[3] : '';

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
                          _onTabClosed(components.indexOf(comp));
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

  List<Widget> _getChildren(List<IComponent> components) {
    List<Widget> children = <Widget>[];

    components.forEach((comp) {
      children.add(comp.getWidget());
    });

    return children;
  }
}
