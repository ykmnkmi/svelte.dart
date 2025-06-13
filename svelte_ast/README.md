# svelte_ast

[![Pub Package][pub_icon]][pub]

Parser and utilities for the [SvelteDart][svelte_dart] template compiler.
Based on the original [Svelte 5][svelte_5] (v5.16.6) parser. Top-level scripts,
styles and template expressions are parsed using [`analyzer`][analyzer] and
[`csslib][csslib].

## Usage

```dart
import 'dart:convert';

import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_ast/mirror_mapper.dart';

const String content = '''
<script>
  int count = 0;
</script>

<button on:click="{() => count++}">count: {count}</button>''';

void main() {
  // Create an AST tree by parsing a template.
  Root root = parse(content);

  // Print to console.
  print(const JsonEncoder.withIndent('  ').convert(root.toJson(mapper)));
}
```

[pub_icon]: https://img.shields.io/pub/v/svelte_ast.svg
[pub]: https://pub.dev/packages/svelte_ast
[svelte_dart]: https://github.com/ykmnkmi/svelte.dart
[svelte_5]: https://svelte.dev
[analyzer]: https://pub.dev/packages/analyzer
[csslib]: https://pub.dev/packages/csslib