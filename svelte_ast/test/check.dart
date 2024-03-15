// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/reflection.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String string = r'''
<!-- app.svelte -->
<script>
  // imports
  import 'package:svelte/svelte.dart';

  // properties
  external int count = 0;

  // body
  $: doubled = count * 2;
  $: quadrupled = doubled * 2;

  void handleClick() {
    count += 1;
  }

  const duration = Duration(seconds: 1);

  onMount(() {
    var timer = Timer.periodic(duration, (_) {
      count += 1;
    });

    return () {
      timer.cancel();
    };
  });
</script>

<button on:click={handleClick}>
  Clicked {count} {count == 1 ? 'time' : 'times'}
</button>

<p>{count} * 2 = {doubled}</p>
<p>{doubled} * 2 = {quadrupled}</p>

<style>
  button {
    background-color: #ff3e00;
    color: white;
    padding: 8px 16px;
    font-size: 16px;
    border: none;
    cursor: pointer;
  }

  button:hover {
    background-color: #ff6f40;
  }

  p {
    margin-top: 8px;
  }
</style>
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
