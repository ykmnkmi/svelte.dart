import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/html.dart';
import 'package:svelte_ast/src/parser.dart';

final RegExp textEndRe = RegExp('[<{]');

extension TextParser on Parser {
  Text? text() {
    var found = template.indexOf(textEndRe, position);

    if (found == -1) {
      if (isDone) {
        return null;
      }

      found = template.length;
    }

    var raw = template.substring(position, found);
    var data = decodeCharacterReferences(raw);

    var node = Text(
      start: position,
      end: found,
      raw: raw,
      data: data,
    );

    position = found;
    return node;
  }
}
