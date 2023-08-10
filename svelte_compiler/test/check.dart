// ignore_for_file: avoid_print

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_compiler/svelte_compiler.dart';

const String source = '''
<script>
  var count = 0;
</script>
<button on:click="{() => count++}">count: {count}</button>''';

void main() {
  try {
    compile(source, options: CompileOptions(fileName: 'app.svelte'));
  } on CompileError catch (error, stackTrace) {
    print(error.message());
    print(Trace.format(stackTrace));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
