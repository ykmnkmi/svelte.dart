import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parse/errors.dart';
import 'package:nutty/src/compiler/parse/parse.dart';

extension StyleParser on Parser {
  static final RegExp styleCloseTagRe = RegExp(r'<\/style\s*>');

  void style(int start, List<Node>? attributes) {
    var content = readUntil(styleCloseTagRe, unclosedStyle);

    if (scan(styleCloseTagRe)) {
      styles.add(Style(start: start, end: index, content: content));
      return;
    }

    unclosedStyle();
  }
}
