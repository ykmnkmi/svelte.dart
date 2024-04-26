const List<int> codes = <int>[0x20, 0x2D, 0x5F];

String _upperCaseFirstLetter(String word) {
  return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
}

List<String> _groupIntoWords(String text) {
  int length = text.length;

  StringBuffer buffer = StringBuffer();
  List<String> words = <String>[];

  bool isAllCaps = text == text.toUpperCase();
  List<int> codeUnits = text.codeUnits;

  for (int index = 0; index < length; index++) {
    int char = codeUnits[index];

    int? nextChar = index + 1 == length ? null : codeUnits[index + 1];

    if (codes.contains(char)) {
      continue;
    }

    buffer.writeCharCode(char);

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
  return _groupIntoWords(text).map<String>(_upperCaseFirstLetter).join();
}
