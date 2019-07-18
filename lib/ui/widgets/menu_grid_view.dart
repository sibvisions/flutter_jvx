import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';

class MenuGridView extends StatelessWidget {
  final List<MenuItem> items;
  
  MenuGridView({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(10.0),
      childAspectRatio: 5.0 / 5.0,
      children: _getGridViewItems(context),
    );
  }

  _getGridViewItems(BuildContext context) {
    List<Widget> widgets = new List<Widget>();
    for (int i = 0; i < items.length; i++) {
      var widget = _getGridItemUI(context, items[i]);
      widgets.add(widget);
    }
    return widgets;
  }

  _getGridItemUI(BuildContext context, MenuItem item) {
    return new InkWell(
      onTap: () {
        
      },
      child: new Card(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*
            new Image.network(
              item.image,
              fit: BoxFit.fill
            ),
            */
            new Expanded(
              child: new Center(
                child: new Column(
                  children: <Widget>[
                    new SizedBox(height: 8.0,),
                    new Text(
                      item.action.label,
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    new Text(item.group),
                    new Text(item.action.componentId, textAlign: TextAlign.center,)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}