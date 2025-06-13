const List<int> codes = <int>[0x20, 0x2D, 0x5F];

String upperCaseFirstLetter(String word) {
  return '${word.substring(0, 1).toUpperCase()}${word.substring(1)}';
}

List<String> groupIntoWords(String text) {
  int length = text.length;

  StringBuffer buffer = StringBuffer();
  List<String> words = <String>[];

  bool isAllCaps = text == text.toUpperCase();
  List<int> codeUnits = text.codeUnits;

  for (int index = 0; index < length; index++) {
    int char = codeUnits[index];

    if (codes.contains(char)) {
      continue;
    }

    buffer.writeCharCode(char);

    int? nextChar = index + 1 == length ? null : codeUnits[index + 1];

    if (nextChar == null ||
        nextChar >= 0x41 && nextChar <= 0x5A && !isAllCaps ||
        codes.contains(nextChar)) {
      words.add(buffer.toString());
      buffer.clear();
    }
  }

  return words;
}

String pascalCase(String text) {
  return groupIntoWords(text).map<String>(upperCaseFirstLetter).join();
}

String camelCase(String text) {
  String result = pascalCase(text);
  return result.substring(0, 1).toLowerCase() + result.substring(1);
}
