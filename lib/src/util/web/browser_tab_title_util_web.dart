import 'package:web/web.dart' as web;

/// {@template browser_tab_title_util.tab_title}
/// Sets the title of the browser tab on web.
///
/// This is a no-op on non-web platforms.
/// {@endtemplate}
setTabTitle(String title) {
    web.document.title = title;
}