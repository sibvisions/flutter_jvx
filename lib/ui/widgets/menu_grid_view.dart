import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class MenuGridView extends StatelessWidget {
  final List<MenuItem> items;
  
  MenuGridView({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new GridView.builder(
      itemCount: this.items.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2
      ),
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                items[index].image != null 
                  ? new CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: !items[index].image.startsWith('FontAwesome') 
                            ? new Image.asset('${globals.dir}${items[index].image}')
                            : _iconBuilder(formatFontAwesomeText(items[index].image))
                  )
                  : new Text(""),
                Align(child: Text(items[index].action.label), alignment: Alignment.bottomCenter,)
              ],
            ),
          ),
          onTap: () { },
        );
      },
    );
  }

  Icon _iconBuilder(Map data) {
    Icon icon = new Icon(
      data['icon'],
      size: double.parse(data['size']),
      color: UIData.ui_kit_color_2,
      key: data['key'],
      textDirection: data['textDirection'],
    );

    return icon;
  }
}