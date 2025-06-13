// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:svelte_ast/mirror_mapper.dart';
import 'package:svelte_ast/svelte_ast.dart';

const DeepCollectionEquality equality = DeepCollectionEquality.unordered();

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

void main() {
  Uri uri = Uri(path: 'test/parser/samples');
  Directory directory = Directory.fromUri(uri);

  for (FileSystemEntity sample in directory.listSync()) {
    generate(sample);
  }
}

void generate(FileSystemEntity sample) {
  File file;
  String content;

  Map<String, Object?>? options;
  Root root;

  Object? actual, expected;

  try {
    file = File.fromUri(sample.uri.resolve('options.json'));

    if (file.existsSync()) {
      content = file.readAsStringSync();
      options = json.decode(content) as Map<String, Object?>?;

      if (options != null) {
        if (options.containsKey('css')) {
          throw UnimplementedError('Skip CSS.');
        }
      }
    }

    file = File.fromUri(sample.uri.resolve('input.svelte'));
    content = file.readAsStringSync();
    root = parse(content, uri: file.uri);
    actual = root.toJson(mapper);

    file = File.fromUri(sample.uri.resolve('output.json'));

    if (file.existsSync()) {
      expected = json.decode(file.readAsStringSync());
    } else {
      print('${sample.path}: error expected');
      return;
    }
  } on ParseError catch (error) {
    actual = error.toJson();
    file = File.fromUri(sample.uri.resolve('error.json'));

    if (file.existsSync()) {
      expected = json.decode(file.readAsStringSync());
    } else {
      print('${sample.path}: output expected');
      return;
    }
  } catch (error) {
    print('${sample.path}: $error');
    return;
  }

  if (equality.equals(actual, expected)) {
    return;
  }

  file.writeAsStringSync(encoder.convert(actual));
  print('${sample.path}: done');
}
