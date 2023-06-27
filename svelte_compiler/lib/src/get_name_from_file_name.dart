final RegExp _slashesRe = RegExp('[/\\\\]');

final RegExp _indexRe = RegExp('^index(\\.\\w+)');

final RegExp _fileEndingRe = RegExp('\\.[^.]+\$');

final RegExp _invalidVariableIdentifierRe = RegExp('[^a-zA-Z_\$0-9]+');

final RegExp _mayStartsOrEndsWithUnderscoreRe = RegExp('^_?(.+?)_?\$');

final RegExp _startsWithDigitRe = RegExp('^(\\d)');

String? getNameFromFileName(String? fileName) {
  if (fileName == null) {
    return null;
  }

  List<String> parts =
      fileName.split(_slashesRe).map<String>(Uri.encodeComponent).toList();

  if (parts.length > 1) {
    RegExpMatch? indexMatch = _indexRe.firstMatch(parts.last);

    if (indexMatch != null) {
      parts.removeLast();
      parts.last += indexMatch[1]!;
    }
  }

  String base = parts
      .removeLast()
      .replaceAll('%', 'u')
      .replaceAll(_fileEndingRe, '')
      .replaceAll(_invalidVariableIdentifierRe, '_')
      .replaceAllMapped(_mayStartsOrEndsWithUnderscoreRe, (match) => match[1]!)
      .replaceAllMapped(_startsWithDigitRe, (match) => '_${match[1]}');

  if (base.isEmpty) {
    throw FormatException(
        'Could not derive component name from file $fileName');
  }

  return base[0].toUpperCase() + base.substring(1);
}
