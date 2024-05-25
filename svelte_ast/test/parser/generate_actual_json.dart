// ignore_for_file: avoid_print

import 'dart:convert' show JsonEncoder, json;
import 'dart:io' show Directory, File, FileSystemEntity;
import 'dart:isolate' show Isolate;

import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'package:svelte_ast/src/reflection.dart' show mapper;
import 'package:svelte_ast/svelte_ast.dart' show ParseError, SvelteAst, parse;

const DeepCollectionEquality equality = DeepCollectionEquality.unordered();

const JsonEncoder encoder = JsonEncoder.withIndent('\t');

void main() {
  Uri uri = Uri(path: 'test/parser/samples');
  Directory directory = Directory.fromUri(uri);

  for (FileSystemEntity sample in directory.listSync()) {
    Isolate.run<void>(() {
      doIt(sample);
    });
  }
}

void doIt(FileSystemEntity sample) {
  File file;
  String content;

  Map<String, Object?>? options;
  SvelteAst ast;

  Object? actual, expected;

  try {
    bool skipStyle = false;
    file = File.fromUri(sample.uri.resolve('options.json'));

    if (file.existsSync()) {
      content = file.readAsStringSync();
      options = json.decode(content) as Map<String, Object?>?;

      if (options != null) {
        if (options.containsKey('css')) {
          skipStyle = options['css'] == 'none';
        }
      }
    }

    file = File.fromUri(sample.uri.resolve('input.svelte'));
    content = file.readAsStringSync();
    ast = parse(content, uri: file.uri, skipStyle: skipStyle);
    actual = ast.toJson(mapper);

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
    print('${sample.path}: not modified');
    return;
  }

  file.writeAsStringSync(encoder.convert(actual));
  print('${sample.path}: done');
}
