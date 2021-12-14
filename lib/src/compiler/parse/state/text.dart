import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

extension TextParser on Parser {
  static late final RegExp openRe = compile(r'[{<]');

  void text() {
    var found = template.indexOf(openRe, index);

    if (found == -1) {
      current.add(Node(type: 'Text', data: rest));
      index = template.length;
      return;
    }

    current.add(Node(type: 'Text', data: template.substring(index, found)));
    index = found;
  }
}
