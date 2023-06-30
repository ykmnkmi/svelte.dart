final RegExp _return = RegExp('\r');

String hash(String string) {
  string = string.replaceAll(_return, '');

  int hash = 5381;
  int index = string.length;

  while ((index -= 1) > 0) {
    hash = ((hash << 5) - hash) ^ string.codeUnitAt(index);
  }

  return (hash >>> 0).toRadixString(36);
}
