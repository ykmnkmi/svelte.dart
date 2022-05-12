import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:collection/collection.dart' show MapEquality;
import 'package:piko/compiler.dart' show parse;
import 'package:path/path.dart' show basename, join, normalize;
import 'package:piko/src/compiler/parse/errors.dart' show CompileError;
import 'package:test/test.dart';

const MapEquality<Object?, Object?> mapEquality = MapEquality<Object?, Object?>();

void main() {
  group('parser', () {
    var dirs = Directory(normalize('test/parser/samples')).listSync();

    for (var dir in dirs) {
      var input = File(join(dir.path, 'input.piko')).readAsStringSync();

      Map<String, Object?>? current;
      Object? expected;
      Object? skip;

      void callback() {
        expect(current, equals(expected));
      }

      try {
        current = parse(input).toJson();
        expected = json.decode(File(join(dir.path, 'output.json')).readAsStringSync());
      } on CompileError catch (error) {
        skip = error.message;
      } catch (error) {
        skip = '$error';
      }

      test('sample: ${basename(dir.path)}', callback, skip: skip);
    }
  });
}
