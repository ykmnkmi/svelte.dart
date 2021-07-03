import 'package:expression/variable.dart';
import 'package:ng/compiler.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

const String template = '''
<script>
  final name = 'world';
</script>

<h1 title="message">hello world!</h1>
''';

void main() {
  try {
    final nodes = Compiler.parse(template);
    print(Compiler.compileNodes(nodes, exports: <Variable>[Variable(name: 'name')]));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
