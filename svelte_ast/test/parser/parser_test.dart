@TestOn('vm')
library;

import 'dart:convert' show JsonEncoder, json;
import 'dart:io' show Directory, File, FileSystemEntity;

import 'package:svelte_ast/reflection.dart' show mapper;
import 'package:svelte_ast/svelte_ast.dart' show ParseError, SvelteAst, parse;
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
        bool skipStyle = false;
        options = parseFile(sample.uri.resolve('options.json'));

        if (options != null) {
          if (options['css'] is String) {
            skipStyle = options['css'] == 'none';
          }
        }

        File input = File.fromUri(sample.uri.resolve('input.svelte'));
        String content = input.readAsStringSync();
        SvelteAst ast = parse(content, uri: input.uri, skipStyle: skipStyle);
        actual = ast.toJson(mapper);
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

      test(sample.path, callback, skip: skip);
    }
  });
}
