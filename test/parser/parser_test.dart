import 'dart:convert' show JsonEncoder, json;
import 'dart:io' show Directory, File;

import 'package:svelte/compiler.dart' show parse;
import 'package:svelte/src/compiler/parser/errors.dart' show ParseError;
import 'package:svelte/src/compiler/parser/parser.dart' show CssMode;
import 'package:test/test.dart' show equals, expect, group, test;

const JsonEncoder encoder = JsonEncoder.withIndent('\t');

Map<String, Object?>? parseFile(Uri uri) {
  var file = File.fromUri(uri);

  if (file.existsSync()) {
    return json.decode(file.readAsStringSync()) as Map<String, Object?>;
  }

  return null;
}

void main() {
  group('Parser', () {
    var uri = Uri(path: 'test/parser/samples');
    var directory = Directory.fromUri(uri);

    for (var sample in directory.listSync()) {
      Map<String, Object?>? options, actual, expected;
      String? skip;

      void callback() {
        expect(actual, equals(expected));
      }

      try {
        CssMode? cssMode;
        options = parseFile(sample.uri.resolve('options.json'));

        if (options != null) {
          if (options['css'] is String) {
            cssMode = CssMode.values.byName(options['css'] as String);
          }
        }

        var input = File.fromUri(sample.uri.resolve('input.svelte'));
        var content = input.readAsStringSync();
        var ast = parse(content, sourceUrl: input.path, cssMode: cssMode);
        actual = ast.toJson();
        expected = parseFile(sample.uri.resolve('output.json'));

        if (expected == null) {
          skip = 'error expected';
        }
      } on ParseError catch (error) {
        actual = error.toJson();
        expected = parseFile(sample.uri.resolve('error.json'));

        if (expected == null) {
          skip = 'output expected';
        }
      } catch (error) {
        skip = '$error';
      }

      test(sample.uri.pathSegments[3], callback, skip: skip);
    }
  });
}
