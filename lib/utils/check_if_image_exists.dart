import 'dart:io';

bool checkIfImageExists(String path) {
  if (path == null)
    return false;
    
  File file = File(path);

  List<int> content = file.readAsBytesSync();

  if (content == null)
    return false;

  return true;
}