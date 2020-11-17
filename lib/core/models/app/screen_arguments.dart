import '../api/response.dart';
import '../api/response/menu_item.dart';

class ScreenArguments {
  final String title;
  final Response response;
  final String menuComponentId;
  final String templateName;
  final List<MenuItem> items;

  ScreenArguments({
    this.title,
    this.menuComponentId,
    this.templateName,
    this.items,
    this.response,
  });
}
