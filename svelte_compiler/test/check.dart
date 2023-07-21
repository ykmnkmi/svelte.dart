// ignore_for_file: avoid_print

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_compiler/svelte_compiler.dart';

const String source = '''
<script context="module">
	var foo;
</script>

<!-- svelte-ignore unused-export-let module-script-reactive-declaration -->
<script>
	external var unused;

	\$: reactive = foo;
</script>
''';

const CompileOptions compilerOptions = CompileOptions(
  fileName: 'app.svelte',
);

void main() {
  try {
    compile(source, options: compilerOptions);
  } on CompileError catch (error, stackTrace) {
    print(error.message());
    print(Trace.format(stackTrace));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
