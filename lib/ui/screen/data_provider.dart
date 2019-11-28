
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';

class DataProvider extends InheritedWidget {
  final JVxData data;

  const DataProvider({Key key, @required this.data, @required Widget child})
      : assert(data != null),
        assert(child != null),
        super(key: key, child: child);

  static JVxData of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(DataProvider) as DataProvider)
          .data;

  @override
  bool updateShouldNotify(DataProvider oldWidget) => data != oldWidget.data;
}