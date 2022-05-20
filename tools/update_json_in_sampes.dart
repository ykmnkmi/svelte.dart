import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:piko/compiler.dart' show parse;
import 'package:piko/src/compiler/parse/errors.dart' show CompileError;

const encoder = JsonEncoder.withIndent('  ');
void main() {
  var samples = Directory.fromUri(Uri.file('test/parser/samples')).listSync();

  for (var sample in samples) {
    var file = File.fromUri(sample.uri.resolveUri(Uri.file('input.piko')));
    var content = file.readAsStringSync();

    try {
      var current = parse(content).toJson();
      file = File.fromUri(sample.uri.resolveUri(Uri.file('output.json')));
      content = encoder.convert(current);
    } on CompileError catch (error) {
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
