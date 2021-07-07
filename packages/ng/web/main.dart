import 'package:expression/variable.dart';
import 'package:ng/compiler.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

const String template = '''
<script>
  var count = 0;

  void handleClick() {
    count += 1;
  }
</script>

<button (click)="handleClick">Clicked {{ count }} {{ count == 1 ? 'time' : 'times' }}</button>
''';

void main() {
  try {
    print(Compiler.compile(template, exports: <Variable>[Variable(name: 'name')]));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
