import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

extension TextParser on Parser {
  static late final RegExp openRe = compile(r'[{<]');

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

    var node = Node(start: start, end: found, type: 'Text', data: data);
    current.children!.add(node);
    index = found;
  }
}
