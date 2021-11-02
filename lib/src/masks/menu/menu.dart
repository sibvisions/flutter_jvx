import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/masks/menu/jvx_menu_widget.dart';
import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_changed_event.dart';
import 'package:flutter_jvx/src/services/menu/i_menu_service.dart';
import 'package:flutter_jvx/src/services/service.dart';
import 'package:flutter_jvx/src/util/mixin/events/on_menu_changed_event.dart';

class Menu extends StatefulWidget{

  const Menu({Key? key}): super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with OnMenuChangedEvent {


  IMenuService menuService = services<IMenuService>();
  JVxMenu menu = JVxMenu();
  StreamSubscription? menuChangedSubscription;

  _MenuState(){
    JVxMenu? serviceMenu = menuService.getMenu();
    if(serviceMenu != null){
      menu = serviceMenu;
    }
    menuChangedSubscription = menuChangedStream.listen(_receivedMenuChangedEvent);
  }


  _getMenuFromService(){
    setState(() {
      JVxMenu? serviceMenu = menuService.getMenu();
      if(serviceMenu != null){
        menu = serviceMenu;
      }
    });
  }

  _receivedMenuChangedEvent(MenuChangedEvent event){
    _getMenuFromService();
  }

  @override
  void dispose() {
    StreamSubscription? temp = menuChangedSubscription;
    if(temp != null){
      temp.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return(
      Scaffold(
        appBar: AppBar(

        ),

        body: JVxMenuWidget(menuGroups: menu.menuGroups,),
      )
    );
  }
}