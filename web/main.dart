import 'package:angular_ast/angular_ast.dart' show HumanizingTemplateAstVisitor, ParserException hide parse;
import 'package:stack_trace/stack_trace.dart' show Trace;

import 'package:piko/compiler.dart';

const String sourceUrl = 'app.html';
const String template = '<h1>Hello {{name}}!</h1>';

void main() {
  try {
    var nodes = parse(template, sourceUrl: sourceUrl);
    var visitor = const HumanizingTemplateAstVisitor();

    for (var node in nodes) {
      print(node);
      print('>> ${node.accept(visitor)}');
    }

    print(compileNodes('App', nodes));
  } on ParserException catch (error, stackTrace) {
    var trace = Trace.from(stackTrace);
    print(error.errorCode.message);

    for (var frame in trace.frames) {
      if (frame.isCore) continue;
      print(frame);
    }
  }
}

// ignore_for_file: avoid_print
