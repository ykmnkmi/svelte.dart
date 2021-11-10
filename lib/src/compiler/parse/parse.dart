import 'package:string_scanner/string_scanner.dart' show StringScanner;

import '../utils/patterns.dart';
import '../interface.dart';

import 'errors.dart';
import 'state/fragment.dart';

class Parser {
  Parser(String template, {Object? sourceUrl})
      : scanner = StringScanner(template.trimRight(), sourceUrl: sourceUrl),
        stack = <Node>[],
        root = Fragment() {
    stack.add(root);

    parse();
  }

  final StringScanner scanner;

  final List<Node> stack;

  Fragment root;

  String get template {
    return scanner.string;
  }

  int get index {
    return scanner.position;
  }

  set index(int index) {
    scanner.position = index;
  }

  String get rest {
    return scanner.rest;
  }

  Node get current {
    return stack.last;
  }

  bool get isDone {
    return scanner.isDone;
  }

  Never error(String code, String message) {
    scanner.error(message);
  }

  bool match(Pattern pattern) {
    return scanner.matches(pattern);
  }

  bool scan(Pattern pattern) {
    return scanner.scan(pattern);
  }

  void expect(Pattern pattern) {
    if (scan(pattern)) {
      return;
    }

    if (isDone) {
      unexpectedEOF(pattern);
    }

    unexpectedToken(pattern);
  }

  void allowWhitespace() {
    scan(whitespace);
  }

  void parse() {
    while (index < template.length) {
      fragment();
    }
  }
}

Node parse(String template, {Object? sourceUrl}) {
  var parser = Parser(template, sourceUrl: sourceUrl);
  return parser.root;
}
