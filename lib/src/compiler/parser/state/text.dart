import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parser/html.dart';
import 'package:nutty/src/compiler/parser/parser.dart';

extension TextParser on Parser {
  static final RegExp textEndRe = RegExp('[{<]');

  void text() {
    var start = index;
    var found = template.indexOf(textEndRe, index);

    String data;

    if (found == -1) {
      if (canParse) {
        data = rest;
        found = template.length;
      } else {
        return;
      }
    } else {
      data = template.substring(start, found);
    }

    current.children.add(Text(
        start: start,
        end: found,
        raw: data,
        data: decodeCharacterReferences(data)));
    index = found;
  }
}
