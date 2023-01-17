import 'package:svelte/src/compiler/parser/parser.dart';

final RegExp svelteIgnoreRe = RegExp(
  '^\\s*svelte-ignore\\s+([\\s\\S]+)\\s*\$',
  multiLine: true,
);

List<String>? extractSvelteIgnore(String data) {
  var match = svelteIgnoreRe.firstMatch(data);

  if (match == null) {
    return null;
  }

  return match[1]!
      .split(spaceRe)
      .map<String>((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}
