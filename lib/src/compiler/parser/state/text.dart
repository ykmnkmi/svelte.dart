import 'package:nutty/src/compiler/ast.dart';
import 'package:nutty/src/compiler/parser/html.dart';
import 'package:nutty/src/compiler/parser/parser.dart';

final RegExp textEndRe = RegExp('[{<]');

extension TextScanner on Parser {
  void text() {
    var found = template.indexOf(textEndRe, position);

    if (found == -1) {
      if (isNotDone) {
        found = template.length;
      } else {
        return;
      }
    }

    var text = decodeCharacterReferences(template.substring(position, found));
    var node = Text(start: position, end: position = found, text: text);
    current.children.add(node);
  }
}
