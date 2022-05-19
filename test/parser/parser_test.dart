import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:piko/compiler.dart' show parse;
import 'package:path/path.dart' show basename, join, normalize;
import 'package:piko/src/compiler/parse/errors.dart' show CompileError;
import 'package:test/test.dart';

void main() {
  group('parser', () {
    var dirs = Directory(normalize('test/parser/samples')).listSync();

    for (var dir in dirs) {
      var input = File(join(dir.path, 'input.piko')).readAsStringSync();

      Object? current, expected;
      Object? skip;

      void callback() {
        expect(current, equals(expected));
      }

      try {
        current = parse(input).toJson();

        var file = File(join(dir.path, 'output.json'));

        if (file.existsSync()) {
          expected = json.decode(file.readAsStringSync());
        } else {
          skip = '${dir.path}: error.json expected';
        }
      } on CompileError catch (error) {
        current = error.toJson();

        var file = File(join(dir.path, 'error.json'));

        if (file.existsSync()) {
          expected = json.decode(file.readAsStringSync());
        } else {
          skip = '${dir.path}: output.json expected';
        }
      } catch (error) {
        skip = '${dir.path}: error';
      }

      test('sample: ${basename(dir.path)}', callback, skip: skip);
    }
  });
}
