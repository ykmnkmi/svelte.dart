# svelte_ast

Parser and utilities for [SvelteDart][svelte_dart] templates.

[svelte_dart]: https://github.com/ykmnkmi/svelte.dart

## Usage

```dart
import 'package:svelte_ast/svelte_ast.dart';

void main() {
  // Create an AST tree by parsing an SvelteDart template.
  var tree = parse('<button title={someTitle}>Hello World!</button>');

  // Print to console.
  print(tree);

  // Output:
  // [
  //    Element <button> {
  //      properties=
  //        Property {
  //          title="Expression {someTitle}"}
  //          childNodes=Text {Hello World!}
  //      }
  //    }
  // ]
}
```
