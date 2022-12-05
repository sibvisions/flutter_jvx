import 'set_url_strategy_stub.dart' if (dart.library.html) 'set_url_strategy_impl.dart' as url_strategy;

void fixUrlStrategy() {
  url_strategy.setHashUrlStrategy();
}
