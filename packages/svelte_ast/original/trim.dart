import 'patterns.dart';

String trimStart(String string) {
  return string.replaceAll(startsWithSpaces, '');
}
