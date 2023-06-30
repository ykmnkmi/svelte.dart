import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_compiler/src/compile_options.dart';
import 'package:svelte_compiler/src/errors.dart';
import 'package:svelte_compiler/svelte_compiler.dart';

const String source = r'''
<svelte:options immutable/>

<script>
	external var count = 0;
	external var foo = (bar: 'baz');

	$: if (foo) count += 1;
</script>

<div>
	<h3>Called {count} times.</h3>
</div>
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
