import 'package:string_scanner/string_scanner.dart';

import 'errors.dart';
import 'nodes.dart';
import 'states.dart';

class Parser {
  Parser(String template, {Object? sourceUrl, int? position})
      : scanner = StringScanner(template.trimRight(), sourceUrl: sourceUrl, position: position),
        stack = <Node>[],
        html = Fragment() {
    stack.add(html);

    while (!isDone) {
      if (match('<')) {
        tag(this);
      } else if (match('{')) {
        mustache(this);
      } else {
        text(this);
      }
    }
  }

  final StringScanner scanner;

  final List<Node> stack;

  final Fragment html;

  Node get current {
    return stack.last;
  }

  int get index {
    return scanner.position;
  }

  set index(int index) {
    scanner.position = index;
  }

  bool get isDone {
    return scanner.isDone;
  }

  String get template {
    return scanner.string;
  }

  Never error({String? message}) {
    throw CompileError(message);
  }

  void add(Node node) {
    current.children.add(node);
  }

  void push(Node node) {
    stack.add(node);
  }

  Node pop() {
    return stack.removeLast();
  }

  @override
  String toString() {
    return 'Parser { ${stack.join(', ')} }';
  }
}

extension ParserMethods on Parser {
  bool eat(String pattern, {bool required = false, String? message}) {
    if (scanner.scan(pattern)) {
      return true;
    }

    if (required) {
      error(message: "expected '$pattern', got '${template[index]} at $index'");
    }

    return false;
  }

  bool match(Pattern pattern) {
    return scanner.matches(pattern);
  }

  String? peekChar([int offset = 0]) {
    offset += index;

    if (offset < 0 || offset >= template.length) {
      return null;
    }

    return template[0];
  }

  bool read(Pattern pattern) {
    return scanner.scan(pattern);
  }

  String readChar() {
    if (isDone) {
      error(message: 'unexpected end of input');
    }

    return template[index++];
  }

  String readUntil(Pattern pattern) {
    if (isDone) {
      error(message: 'unexpected end of input');
    }

    final start = index;

    while (!isDone && !match(pattern)) {
      index += 1;
    }

    return template.substring(start, index);
  }

  void whitespace({bool required = false}) {
    const whitespaces = <int>[32, 9, 10, 13];

    if (required) {
      error(message: 'expected whitespace');
    }

    while (!scanner.isDone && whitespaces.contains(scanner.peekChar())) {
      index += 1;
    }
  }
}
