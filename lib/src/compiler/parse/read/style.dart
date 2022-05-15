import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/parse/errors.dart';

extension StyleParser on Parser {
  static final RegExp closeRe = RegExp(r'<\/style\s*>');

  // static late final RegExp allRe = compile(r'[^\n]');

  void style(int start, List<Node>? attributes) {
    var data = readUntil(closeRe, unclosedStyle);

    if (scan(closeRe)) {
      // TODO(style): parse and tidy up AST
      styles.add(Style(start: start, end: index, data: data));
      return;
    }

    unclosedStyle();
  }
}
