final RegExp ignoreRe = RegExp('^\\s*ignore:\\s+([\\s\\S]+)\\s*\$', multiLine: true);

List<String>? extractIgnore(String text) {
  var match = ignoreRe.firstMatch(text);

  if (match == null) {
    return null;
  }

  return match[1]!.split(',').map<String>((rule) => rule.trim()).where((rule) => rule.isNotEmpty).toList();
}
