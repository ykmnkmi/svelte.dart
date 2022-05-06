import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/utils/patterns.dart';
import 'package:piko/src/compiler/parse/errors.dart';

extension StyleParser on Parser {
  static final RegExp closeRe = compile(r'<\/style\s*>');

  // static late final RegExp allRe = compile(r'[^\n]');

  void style(int start, List<Node>? attributes) {
    var data = readUntil(closeRe, unclosedStyle);

    if (scan(closeRe)) {
      // TODO(style): parse and tidy up AST
      scripts.add(Node(start: start, end: index, type: 'Style', data: data));
      return;
    }

    unclosedStyle();
  }
}
