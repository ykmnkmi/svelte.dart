// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/mirror_mapper.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String string = '''
<script>
	import 'package:svelte/svelte.dart' show onMount;

	import 'foo.dart' deferred as foo;

	onMount(() async {
		await foo.loadLibrary();
		print(foo.message);
	});
</script>
''';

void main() {
  try {
    SvelteAst ast = parse(
      string,
      fileName: 'check.dart',
      uri: Uri.file('check.dart'),
    );

    Map<String, Object?> json = ast.toJson(mapper);
    String output = const JsonEncoder.withIndent('  ').convert(json);
    File.fromUri(Uri(path: 'test/check.json')).writeAsStringSync(output);
    print(output);
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(error.span.highlight());
    print(Trace.format(stackTrace));
    print(const JsonEncoder.withIndent('  ').convert(error.toJson()));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
