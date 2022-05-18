import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/parse/errors.dart';

extension StyleParser on Parser {
  static final RegExp styleCloseTagRe = RegExp(r'<\/style\s*>');

  void style(int start, List<Node>? attributes) {
    var data = readUntil(styleCloseTagRe, unclosedStyle);

    if (scan(styleCloseTagRe)) {
      // TODO(style): parse and tidy up AST
      styles.add(Style(start: start, end: index, data: data));
      return;
    }

    unclosedStyle();
  }
}
