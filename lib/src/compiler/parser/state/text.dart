import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parser/html.dart';
import 'package:nutty/src/compiler/parser/parser.dart';

final RegExp textEndRe = RegExp('[<{]');

extension TextScanner on Parser {
  void text() {
    var found = template.indexOf(textEndRe, position);

    if (found == -1) {
      if (isDone) {
        return;
      }

      found = template.length;
    }

    var raw = template.substring(position, found);
    var text = decodeCharacterReferences(raw);

    current.children.add(Node(
      start: position,
      end: found,
      type: 'Text',
      text: text,
      raw: raw,
    ));

    position = found;
  }
}
