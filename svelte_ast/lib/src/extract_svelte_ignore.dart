final RegExp svelteIgnoreRe = RegExp(
  '^\\s*svelte-ignore\\s+([\\s\\S]+)\\s*\$',
  multiLine: true,
);

List<String> extractSvelteIgnore(String data) {
  var match = svelteIgnoreRe.firstMatch(data);

  if (match == null) {
    return const <String>[];
  }

  return match[1]!
      .split(RegExp('[ \t\r\n]'))
      .map<String>((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}
