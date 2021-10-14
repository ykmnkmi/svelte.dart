import 'package:angular_ast/angular_ast.dart' hide parse;
import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const String sourceUrl = 'app.html';
const String template = '<button (click)="log()" id="greeter">hello {{ name }}!</button>';
void main() {
  try {
    var nodes = parse(template, sourceUrl: sourceUrl);
    var visitor = const HumanizingTemplateAstVisitor();

    for (var node in nodes) {
      print(node);
      print('>> ${node.accept(visitor)}');
    }

    var code = TemplateCompiler('App', nodes).compile();
    print(code);
  } on AngularParserException catch (error, stackTrace) {
    print(error.errorCode.message);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print