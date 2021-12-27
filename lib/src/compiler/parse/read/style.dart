import '../../parse/errors.dart';
import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

extension StyleParser on Parser {
  static late final RegExp closeRe = compile(r'<\/style\s*>');

  // static late final RegExp allRe = compile(r'[^\n]');

  void style(int start, List<Node>? attributes) {
    final data = readUntil(closeRe, unclosedStyle);

    if (scan(closeRe)) {
      // TODO(style): parse and tidy up AST
      scripts.add(Node(start: start, end: index, type: 'Style', data: data));
      return;
    }

    unclosedStyle();
  }
}
