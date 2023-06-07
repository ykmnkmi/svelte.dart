@TestOn('vm')
library;

import 'dart:convert' show JsonEncoder, json;
import 'dart:io' show Directory, File, FileSystemEntity;

import 'package:svelte_ast/svelte_ast.dart'
    show /* CssMode, */ Node, ParseError, parse;
import 'package:test/test.dart' show TestOn, equals, expect, group, test;

const JsonEncoder encoder = JsonEncoder.withIndent('\t');

Map<String, Object?>? parseFile(Uri uri) {
  File file = File.fromUri(uri);

  if (file.existsSync()) {
    return json.decode(file.readAsStringSync()) as Map<String, Object?>;
  }

  return null;
}

void main() {
  group('Parser', () {
    Uri uri = Uri(path: 'test/parser/samples');
    Directory directory = Directory.fromUri(uri);

    for (FileSystemEntity sample in directory.listSync()) {
      Map<String, Object?>? options, actual, expected;
      String? skip;

      void callback() {
        expect(actual, equals(expected));
      }

      try {
        // CssMode? cssMode;
        options = parseFile(sample.uri.resolve('options.json'));

        if (options != null) {
          if (options['css'] is String) {
            // cssMode = CssMode.values.byName(options['css'] as String);
          }
        }

        File input = File.fromUri(sample.uri.resolve('input.svelte'));
        String content = input.readAsStringSync();
        Node ast = parse(content, uri: input.uri /*, cssMode: cssMode */);
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
