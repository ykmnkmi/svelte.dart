# svelte_ast

[![Pub Package][pub_icon]][pub]

Parser and utilities for [SvelteDart][svelte_dart] template compiler.

## Usage

```dart
import 'dart:convert';

import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_ast/mirror_mapper.dart';

const String content = '''
<script>
  var count = 0;
</script>
<button on:click="{() => count++}">count: {count}</button>''';

void main() {
  // Create an AST tree by parsing an SvelteDart template.
  SvelteAst ast = parse(content);

  // Print to console.
  print(const JsonEncoder.withIndent('\t').convert(ast.toJson(mapper)));
}
```

[pub_icon]: https://img.shields.io/pub/v/svelte_ast.svg
[pub]: https://pub.dev/packages/svelte_ast
[svelte_dart]: https://github.com/ykmnkmi/svelte.dart