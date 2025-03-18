String hash(String value) {
  value = value.replaceAll('\r', '');

  int hash = 5381;
  int i = value.length;

  while (i-- > 0) {
    hash = ((hash << 5) - hash) ^ value.codeUnitAt(i);
  }

  return (hash >>> 0).toRadixString(36);
}
