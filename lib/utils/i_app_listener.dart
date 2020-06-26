abstract class IAppListener{
  void addAfterStartupListener(Function afterStartupListener);

  void removeAfterStartupListener(Function afterStartupListener);

  void fireAfterStartupListener(dynamic callBackParameter);
}