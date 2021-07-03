import 'package:expression/expression.dart';
import 'package:expression/variable.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

const String expression = '''user.send('hello', by: 'jhon')''';

void main() {
  try {
    final parser = const ExpressionParser();
    final node = parser.parseAction(expression, <Variable>[Variable(name: 'user')]);
    print(node);
    final compiler = const ExpressionCompiler();
    final code = compiler.visit(node, 'context');
    print(code);
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
