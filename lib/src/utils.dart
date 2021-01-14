extension StringUtils on String {
  bool get isIdentifier {
    if (isEmpty) {
      return false;
    }

    final codes = codeUnits;
    return codes.every(isChar);
  }

  String toLiteral() {
    return '\'' + replaceAll('\'', '\\\'') + '\'';
  }
}

bool isChar(int char) {
  return char >= 97 && char <= 122 || char >= 65 && char <= 90;
}
