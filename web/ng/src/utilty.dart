bool isPrimitive(Object? obj) {
  return obj is num || obj is bool || obj == null || obj is String;
}

List<String> jsSplit(String string, RegExp regExp) {
  final parts = <String>[];
  var lastEnd = 0;

  for (final match in regExp.allMatches(string)) {
    parts.add(string.substring(lastEnd, match.start));
    lastEnd = match.end;

    for (var i = 0, len = match.groupCount; i < len; i++) {
      parts.add(match.group(i + 1)!);
    }
  }

  parts.add(string.substring(lastEnd));
  return parts;
}
