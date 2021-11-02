import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_added_event.dart';
import 'package:flutter_jvx/src/services/content/i_content_store.dart';
import 'package:flutter_jvx/src/util/mixin/events/on_menu_added_event.dart';

class ContentStore with OnMenuAddedEvent implements IContentStore {



  ContentStore(){
    menuAddedEventStream.listen(_receivedMenuAddedEvent);
  }

  _receivedMenuAddedEvent(MenuAddedEvent event) {

  }


  @override
  JVxMenu getMenu() {
    throw UnimplementedError();
  }

}