import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

extension TextParser on Parser {
  static late final RegExp openRe = compile('[{<]');

  void text() {
    var found = template.indexOf(openRe, index);

    if (found == -1) {
      current.add(Text(rest));
      index = template.length;
      return;
    }

    current.add(Text(template.substring(index, found)));
    index = found;
  }
}
