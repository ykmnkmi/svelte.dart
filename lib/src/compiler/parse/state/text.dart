import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/utils/patterns.dart';

extension TextParser on Parser {
  static final RegExp openRe = compile(r'[{<]');

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

    var node = Node.text(start: start, end: found, data: data);
    current.children!.add(node);
    index = found;
  }
}
