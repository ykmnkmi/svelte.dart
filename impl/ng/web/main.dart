import 'package:piko/piko.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

const String template = '''
<script>
  final name = 'world';
</script>

<h1>Hello { name }!</h1>
''';

void main() {
  try {
    final node = const ExpressionParser().parseAction('name', <Variable>[Variable(name: 'name', prefix: 'context')]);
    print(node);
    // print(NgCompiler.compile(template.trim()));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
