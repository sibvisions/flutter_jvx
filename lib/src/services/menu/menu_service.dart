import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_added_event.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_changed_event.dart';
import 'package:flutter_jvx/src/services/menu/i_menu_service.dart';
import 'package:flutter_jvx/src/util/mixin/events/meta/on_menu_added_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/meta/on_menu_changed_event.dart';

class MenuService with OnMenuAddedEvent, OnMenuChangedEvent implements IMenuService {

   MenuService(){
     menuAddedEventStream.listen(_receivedAddedMenuEvent);
   }

   JVxMenu? jVxMenu;


   _receivedAddedMenuEvent(MenuAddedEvent event) {
     jVxMenu = event.menu;
     MenuChangedEvent menuChangedEvent = MenuChangedEvent(reason: "Menu was added via MenuAdded event", origin: this);
     fireMenuChangedEvent(menuChangedEvent);
   }


  @override
  JVxMenu? getMenu() {
     return jVxMenu;
  }

}