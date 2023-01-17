// ignore_for_file: avoid_print

import 'dart:convert' show JsonEncoder, json;
import 'dart:io' show Directory, File, FileSystemEntity, Platform;

import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'package:stack_trace/stack_trace.dart' show Trace;
import 'package:svelte/compiler.dart' show ParseError, parse;

const DeepCollectionEquality equality = DeepCollectionEquality.unordered();

const JsonEncoder encoder = JsonEncoder.withIndent('\t');

void update(FileSystemEntity sample) {
  var file = File.fromUri(sample.uri.resolve('input.svelte'));
  var content = file.readAsStringSync().trimRight();

  Map<String, Object?> actual, expected;

  try {
    actual = parse(content).toJson();
    file = File.fromUri(sample.uri.resolve('output.json'));

    if (!file.existsSync()) {
      print('output expected: ${sample.path}');
    }

    expected = json.decode(file.readAsStringSync()) as Map<String, Object?>;
    file = File.fromUri(sample.uri.resolve('_output.json'));
  } on ParseError catch (parseError) {
    actual = parseError.toJson();
    file = File.fromUri(sample.uri.resolve('error.json'));

    if (!file.existsSync()) {
      print('error expected: ${sample.path}');
    }

    expected = json.decode(file.readAsStringSync()) as Map<String, Object?>;
    file = File.fromUri(sample.uri.resolve('_error.json'));
  } catch (error, stackTrace) {
    print('error: ${sample.path}');
    print(Trace.format(stackTrace));
    return;
  }

  if (equality.equals(actual, expected)) {
    if (file.existsSync()) {
      file.deleteSync();
    }

    return;
  }

  print('not equal: ${sample.path}');
  file.writeAsStringSync(encoder.convert(actual));
}

void main() {
  var uri = Platform.script.resolve('samples');
  var directory = Directory.fromUri(uri);
  directory.listSync().forEach(update);
}
