import 'dart:convert' show JsonDecoder;
import 'dart:io' show File;

Object? loadJSON(String path) {
  return const JsonDecoder().convert(File(path).readAsStringSync());
}
