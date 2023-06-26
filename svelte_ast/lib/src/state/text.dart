import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/html.dart';
import 'package:svelte_ast/src/parser.dart';

final RegExp _textEndRe = RegExp('[<{]');

extension TextParser on Parser {
  void text(int start) {
    int found = string.indexOf(_textEndRe, start);

    if (found == -1) {
      if (isDone) {
        return;
      }

      found = length;
    }

    if (start < found) {
      String raw = string.substring(start, found);
      String data = decodeCharacterReferences(raw, false);

      current.children.add(Text(
        start: start,
        end: found,
        raw: raw,
        data: data,
      ));
    }

    position = found;
  }
}
