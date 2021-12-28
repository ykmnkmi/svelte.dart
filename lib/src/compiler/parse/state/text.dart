import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

extension TextParser on Parser {
  static late final RegExp openRe = compile(r'[{<]');

  void text() {
    final start = index;
    final found = template.indexOf(openRe, index);

    if (found == -1) {
      if (canParse) {
        current.children.add(Node(start: start, end: length, type: 'Text', data: rest));
        index = template.length;
      }

      return;
    }

    current.children.add(Node(start: start, end: found, type: 'Text', data: template.substring(start, found)));
    index = found;
  }
}
