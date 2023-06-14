import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/html.dart';

import '../parser.dart';

final RegExp _textEndRe = RegExp('[<{]');

extension TextParser on Parser {
  void text() {
    int found = string.indexOf(_textEndRe, position);

    if (found == -1) {
      if (isDone) {
        return;
      }

      found = length;
    }

    String raw = string.substring(position, found);
    String data = decodeCharacterReferences(raw, false);

    current.children.add(Text(
      start: position,
      end: position = found,
      raw: raw,
      data: data,
    ));
  }
}
