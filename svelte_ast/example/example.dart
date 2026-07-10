// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:svelte_ast/svelte_ast.dart';

const String content = '''
<script>
  import 'dart:async';

  import 'package:svelte/svelte.dart';

  var step = input<int>(1);

  var count = state<int>(0);
  var doubled = derived<int>(() => count() * 2);
  var quadrupled = derived<int>(() => doubled() * 2);

  void handleClick() {
    count.set(count() + step());
  }

  onMount(() {
    var timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count.increment();
    });

    return () {
      timer.cancel();
    };
  });
</script>

<button onclick={handleClick}>
  Clicked {count()} {count() == 1 ? 'time' : 'times'}
</button>

<p>{count()} * 2 = {doubled()}</p>
<p>{doubled()} * 2 = {quadrupled()}</p>''';

void main() {
  // Create an AST tree by parsing an SvelteDart template.
  Root root = parse(content);

  // Print to console.
  print(const JsonEncoder.withIndent('  ').convert(root.toJson()));
}
