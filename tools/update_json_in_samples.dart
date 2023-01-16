import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:nutty/compiler.dart' show ParseError, parse;

const encoder = JsonEncoder.withIndent('  ');

void main(List<String> arguments) {
  for (var argument in arguments) {
    var samples = Directory.fromUri(Uri.file(argument)).listSync();

    for (var sample in samples) {
      var file = File.fromUri(sample.uri.resolveUri(Uri.file('input.nutty')));
      var content = file.readAsStringSync().trimRight();
      file.writeAsStringSync(content);

      try {
        var current = parse(content).toJson();
        file = File.fromUri(sample.uri.resolveUri(Uri.file('output.json')));
        content = encoder.convert(current);
      } on ParseError catch (error) {
        var current = error.toJson();
        file = File.fromUri(sample.uri.resolveUri(Uri.file('error.json')));
        content = encoder.convert(current);
      } catch (error) {
        print('error: ${sample.path}');
        continue;
      }

      if (file.existsSync()) {
        file.writeAsStringSync(content);
      } else {
        print('not matched: ${file.parent.path}');
      }
    }
  }
}

// ignore_for_file: avoid_print
