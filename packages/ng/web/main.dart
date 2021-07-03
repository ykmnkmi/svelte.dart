import 'package:ng/src/compiler.dart';
// import 'package:ng/src/expression/compiler.dart';
// import 'package:ng/src/expression/parser.dart';
import 'package:ng/src/variable.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

const String template = '''
<script>
  final name = 'world';
</script>

<h1>Hello {{ name }}!</h1>
''';

void main() {
  try {
    // final parser = const ExpressionParser();
    // final node = parser.parseAction('name + 1', <Variable>[Variable(name: 'name')]);
    // print(node);
    // final compiler = const ExpressionCompiler();
    // final code = compiler.visit(node, 'context');
    // print(code);
    print(Compiler.compile(template, exports: <Variable>[Variable(name: 'name', string: true)]));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
