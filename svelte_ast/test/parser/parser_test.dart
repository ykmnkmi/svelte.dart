@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:svelte_ast/src/reflection.dart';
import 'package:svelte_ast/svelte_ast.dart';
import 'package:test/test.dart';

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
        options = parseFile(sample.uri.resolve('options.json'));

        if (options != null) {
          if (options['css'] is String) {
            throw UnimplementedError('Skip CSS.');
          }
        }

        File input = File.fromUri(sample.uri.resolve('input.svelte'));
        String content = input.readAsStringSync();
        Root root = parse(content, uri: input.uri);
        actual = root.toJson(mapper);
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
