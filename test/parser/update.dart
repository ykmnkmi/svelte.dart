import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:piko/compiler.dart' show parse;
import 'package:path/path.dart' show join, normalize;
import 'package:piko/src/compiler/parse/errors.dart' show CompileError;

const encoder = JsonEncoder.withIndent('  ');
void main() {
  var dirs = Directory(normalize('test/parser/samples')).listSync();

  for (var dir in dirs) {
    var input = File(join(dir.path, 'input.piko')).readAsStringSync();

    try {
      var current = parse(input).toJson();
      File(join(dir.path, 'output.json')).writeAsStringSync(encoder.convert(current));
    } on CompileError catch (error) {
      var current = error.toJson();
      File(join(dir.path, 'error.json')).writeAsStringSync(encoder.convert(current));
    } catch (error) {
      print('skip: ${dir.path}');
      continue;
    }
  }
}
