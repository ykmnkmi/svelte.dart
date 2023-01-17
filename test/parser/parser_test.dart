import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:svelte/compiler.dart' show parse;
import 'package:svelte/src/compiler/parser/errors.dart' show ParseError;
import 'package:test/test.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('\t');

void main() {
  group('parser', () {
    var uri = Uri.directory('test/parser/samples');
    var dirs = Directory.fromUri(uri).listSync();

    File file;

    for (var dir in dirs) {
      var uri = dir.uri.resolve('input.svelte');
      var input = File.fromUri(uri).readAsStringSync();

      Object? actual, output;
      Object? skip;

      void callback() {
        expect(actual, equals(output));
      }

      try {
        actual = parse(input).toJson();
        file = File.fromUri(uri.resolve('output.json'));

        if (file.existsSync()) {
          output = json.decode(file.readAsStringSync());
        } else {
          skip = '${dir.path}: error expected';
        }
      } on ParseError catch (error) {
        actual = error.toJson();
        file = File.fromUri(uri.resolve('error.json'));

        if (file.existsSync()) {
          output = json.decode(file.readAsStringSync());
        } else {
          skip = '${dir.path}: output expected';
        }
      } catch (error) {
        skip = '${dir.path}: $error';
      }

      test(dir.path, callback, skip: skip);
    }
  });
}
