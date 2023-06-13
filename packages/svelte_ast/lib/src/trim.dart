import 'package:svelte_ast/src/patterns.dart';

String trimStart(String string) {
  return string.replaceAll(startsWithSpaces, '');
}

String trimEnd(String string) {
  return string.replaceAll(endsWithSpaces, '');
}
