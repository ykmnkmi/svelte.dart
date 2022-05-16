import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/utils/html.dart';

extension TextParser on Parser {
  static final RegExp openRe = RegExp(r'[{<]');

  void text() {
    var start = index;
    var found = template.indexOf(openRe, index);

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

    var escaped = decodeCharacterReferences(data);
    addNode(Text(start: start, end: found, data: escaped, raw: data));
    index = found;
  }
}
