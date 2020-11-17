import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../injection_container.dart';
import '../../../utils/theme/theme_manager.dart';
import '../custom/custom_float.dart';

class CommonScaffold extends StatelessWidget {
  final appTitle;
  final Widget bodyData;
  final showFAB;
  final showDropdownButton;
  final showSearchButton;
  final showDrawer;
  final backGroundColor;
  final actionFirstIcon;
  final scaffoldKey;
  final showBottomNav;
  final floatingIcon;
  final centerDocked;
  final elevation;
  final String bottomButton1;
  final String bottomButton2;
  final Function bottomButton1Function;
  final Function bottomButton2Function;
  final List<String> dropdownItems;
  final Function dropdownCallback;
  final Widget drawer;
  final Function qrCallback;
  final showAppBar;

  CommonScaffold(
      {this.appTitle,
      this.bodyData,
      this.showFAB = false,
      this.backGroundColor,
      this.actionFirstIcon = Icons.search,
      this.scaffoldKey,
      this.showBottomNav = false,
      this.centerDocked = false,
      this.floatingIcon,
      this.elevation = 4.0,
      this.bottomButton1,
      this.bottomButton2,
      this.bottomButton1Function,
      this.bottomButton2Function,
      this.showDropdownButton = false,
      this.showSearchButton = false,
      this.dropdownItems,
      this.dropdownCallback,
      this.showDrawer = false,
      this.drawer,
      this.qrCallback,
      this.showAppBar = true});

  Widget myBottomBar() => BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        child: Ink(
          height: 50.0,
          decoration: new BoxDecoration(
              gradient: new LinearGradient(colors: [sl<ThemeManager>().themeData.primaryColor, sl<ThemeManager>().themeData.primaryColor])),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: double.infinity,
                child: new InkWell(
                  radius: 10.0,
                  splashColor: Colors.yellow,
                  onTap: () {
                    this.bottomButton1Function();
                  },
                  child: Center(
                      child: this.bottomButton1 != null
                          ? Text(
                              this.bottomButton1,
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : Text('')),
                ),
              ),
              new SizedBox(
                width: 20.0,
              ),
              SizedBox(
                height: double.infinity,
                child: new InkWell(
                  onTap: () {
                    this.bottomButton2Function();
                  },
                  radius: 10.0,
                  splashColor: Colors.yellow,
                  child: Center(
                      child: this.bottomButton2 != null
                          ? Text(
                              this.bottomButton2,
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : Text('')),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey != null ? scaffoldKey : null,
      backgroundColor: backGroundColor != null ? backGroundColor : null,
      appBar: showAppBar
          ? AppBar(
              elevation: elevation,
              backgroundColor: sl<ThemeManager>().themeData.primaryColor,
              title: Text(appTitle),
              actions: <Widget>[
                SizedBox(
                  width: 5.0,
                ),
                showSearchButton
                    ? actionFirstIcon
                    : SizedBox(
                        width: 5.0,
                      ),
                showDropdownButton
                    ? DropdownButton(
                        icon: FaIcon(
                          FontAwesomeIcons.ellipsisV,
                          color: Colors.black,
                        ),
                        onChanged: (String value) {
                          this.dropdownCallback(value);
                        },
                        items: this
                            .dropdownItems
                            .map((value) => DropdownMenuItem(
                                  child: Text(value),
                                  value: value,
                                ))
                            .toList(),
                      )
                    : SizedBox(
                        width: 5.0,
                      ),
                SizedBox(
                  width: 10.0,
                )
              ],
            )
          : null,
      drawer: showDrawer ? drawer : null,
      body: bodyData,
      floatingActionButton: showFAB
          ? CustomFloat(
              // builder: centerDocked
              //     ? Text(
              //         "5",
              //         style: TextStyle(color: Colors.white, fontSize: 10.0),
              //       )
              //     : null,
              icon: floatingIcon,
              qrCallback: qrCallback,
            )
          : null,
      floatingActionButtonLocation: centerDocked
          ? FloatingActionButtonLocation.centerDocked
          : FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: showBottomNav ? myBottomBar() : null,
    );
  }
}
