// ignore_for_file: avoid_print

import 'dart:convert' show JsonEncoder, json;
import 'dart:io' show Directory, File;

import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'package:svelte/compiler.dart' show ParseError, parse;

const DeepCollectionEquality equality = DeepCollectionEquality.unordered();

const JsonEncoder encoder = JsonEncoder.withIndent('\t');

void main() {
  var uri = Uri(path: 'test/parser/samples');
  var directory = Directory.fromUri(uri);

  for (var sample in directory.listSync()) {
    var input = File.fromUri(sample.uri.resolve('input.svelte'));
    var content = input.readAsStringSync().trimRight();

    Object? actual, expected;
    File? file;

    try {
      actual = parse(content).toJson();
      input = File.fromUri(sample.uri.resolve('output.json'));

      if (input.existsSync()) {
        expected = json.decode(input.readAsStringSync());
        file = input;
      } else {
        print('output expected ${sample.path}');
        continue;
      }
    } on ParseError catch (error) {
      actual = error.toJson();
      input = File.fromUri(sample.uri.resolve('error.json'));

      if (input.existsSync()) {
        expected = json.decode(input.readAsStringSync());
        file = input;
      } else {
        print('error expected ${sample.path}');
      }
    } catch (error) {
      print('error: ${sample.path}');
      continue;
    }

    if (equality.equals(actual, expected)) {
      continue;
    }

    if (file != null) {
      print('not equal: ${sample.path}');
      file.writeAsStringSync(encoder.convert(actual));
    }
  }
}
