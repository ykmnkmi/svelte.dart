import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:angular_ast/angular_ast.dart';

void main() {
  var parse = const Parser().parse;
  var templatesDir = path.join('test', 'e2e', 'templates');

  group('E2E', () {
    for (var file in Directory(templatesDir).listSync()) {
      if (file is File) {
        test('should parse ${path.basenameWithoutExtension(file.path)}', () {
          parse(file.readAsStringSync(), sourceUrl: file.absolute.path);
        });
      }
    }
  });
}
