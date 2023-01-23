import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:svelte/compiler.dart' show parse;
import 'package:svelte/src/compiler/parser/errors.dart' show ParseError;
import 'package:test/test.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('\t');

void main() {
  group('parser', () {
    var uri = Uri(path: 'test/parser/samples');
    var directory = Directory.fromUri(uri);

    for (var sample in directory.listSync()) {
      var input = File.fromUri(sample.uri.resolve('input.svelte'));
      var content = input.readAsStringSync().trimRight();

      Object? actual, expected;
      String? skip;

      void callback() {
        expect(actual, equals(expected));
      }

      try {
        actual = parse(content).toJson();
        input = File.fromUri(sample.uri.resolve('output.json'));

        if (input.existsSync()) {
          expected = json.decode(input.readAsStringSync());
        } else {
          skip = 'output expected ${sample.path}';
        }
      } on ParseError catch (error) {
        actual = error.toJson();
        input = File.fromUri(sample.uri.resolve('error.json'));

        if (input.existsSync()) {
          expected = json.decode(input.readAsStringSync());
        } else {
          skip = 'error expected ${sample.path}';
        }
      } catch (error) {
        skip = 'error: ${sample.path}';
      }

      test(sample.path, callback, skip: skip);
    }
  });
}
