import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:nutty/compiler.dart' show parse;
import 'package:nutty/src/compiler/parse/errors.dart' show CompileError;
import 'package:test/test.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

void main() {
  group('parser', () {
    var dirs =
        Directory.fromUri(Uri.directory('test/parser/samples')).listSync();

    for (var dir in dirs) {
      var uri = Uri.directory(dir.path).resolveUri(Uri.file('input.piko'));
      var input = File.fromUri(uri).readAsStringSync();

      Object? current, expected;
      Object? skip;

      void callback() {
        expect(current, equals(expected));
      }

      try {
        current = parse(input).toJson();

        var file = File.fromUri(uri.resolveUri(Uri.file('output.json')));

        if (file.existsSync()) {
          expected = json.decode(file.readAsStringSync());
        } else {
          skip = '${dir.path}: error.json expected';
        }
      } on CompileError catch (error) {
        current = error.toJson();

        var file = File.fromUri(uri.resolveUri(Uri.file('error.json')));

        if (file.existsSync()) {
          expected = json.decode(file.readAsStringSync());
        } else {
          skip = '${dir.path}: output.json expected';
        }
      } catch (error) {
        skip = '${dir.path}: error';
      }

      test('sample: ${dir.path}', callback, skip: skip);
    }
  });
}
