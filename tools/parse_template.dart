import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte/compiler.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

// const JsonEncoder encoderTab = JsonEncoder.withIndent('  ');

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    exit(1);
  }

  var file = File(arguments.first);

  if (file.existsSync()) {
    try {
      var content = file.readAsStringSync();
      var ast = parse(content);
      var json = ast.toJson();
      print(encoder.convert(json));

      // file = File.fromUri(file.uri.resolve('_actual.json'));
      // file.writeAsStringSync(encoderTab.convert(json));
    } on ParseError catch (error, stackTrace) {
      print(error);
      print(Trace.format(stackTrace));
      print(error.span.highlight(color: true));
      print(encoder.convert(error.toJson()));
    } catch (error, stackTrace) {
      print(error);
      print(Trace.format(stackTrace));
    }
  } else {
    exit(2);
  }
}

// ignore_for_file: avoid_print
