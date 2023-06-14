import 'package:svelte_ast/src/patterns.dart';

String trimStart(String string) {
  return string.replaceFirst(startsWithSpaces, '');
}

String trimEnd(String string) {
  return string.replaceFirst(endsWithSpaces, '');
}
