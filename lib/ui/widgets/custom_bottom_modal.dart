import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../model/so_action.dart' as prefix1;
import '../../model/menu_item.dart';
import '../../ui/widgets/fontAwesomeChanger.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/uidata.dart';

showCustomBottomModalMenu(
    BuildContext context, List<MenuItem> items, Key currentComponentId) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Color(0xFF737373),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                )),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(items[index].action.label),
                  trailing: items[index].image != null
                      ? new CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: !items[index].image.startsWith('FontAwesome')
                              ? new Image.asset(
                                  '${globals.dir}${items[index].image}')
                              : _iconBuilder(
                                  formatFontAwesomeText(items[index].image)))
                      : new CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: FaIcon(
                            FontAwesomeIcons.clone,
                            size: 32,
                            color: Colors.grey[300],
                          )),
                  onTap: () {
                    changeScreen(
                        context, currentComponentId, items[index].action);
                  },
                );
              },
            ),
          ),
        );
      });
}

Icon _iconBuilder(Map data) {
  Icon icon = new Icon(
    data['icon'],
    size: 32,
    color: UIData.ui_kit_color_2[300],
    key: data['key'],
    textDirection: data['textDirection'],
  );

  return icon;
}

changeScreen(BuildContext context, Key componentId, prefix1.SoAction action) {
  globals.changeScreen = action;
  /*

  CloseScreenBloc closeScreenBloc = CloseScreenBloc();
  // StreamSubscription<FetchProcess> closeApiStreamsubscription = apiSubscription(closeScreenBloc.apiResult, context);
  closeScreenBloc.closeScreenSink.add(CloseScreenViewModel(clientId: globals.clientId, componentId: componentId));

  OpenScreenBloc openScreenBloc = OpenScreenBloc();
  StreamSubscription<FetchProcess> apiStreamsubscription = apiSubscription(openScreenBloc.apiResult, context);
  openScreenBloc.openScreenSink.add(OpenScreenViewModel(clientId: globals.clientId, manualClose: true, action: action));
  */
}
