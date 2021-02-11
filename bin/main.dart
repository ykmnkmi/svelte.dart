import 'package:string_scanner/string_scanner.dart';

void main() {
  print(Parser('hello world!').root);
}

enum ParserState {
  text,
}

class Parser {
  Parser(String template, {Object sourceUrl, int position})
      : scanner = StringScanner(template.trimRight(), sourceUrl: sourceUrl, position: position),
        stack = <Node>[],
        root = Fragment(),
        state = ParserState.text {
    stack.add(root);

    while (!scanner.isDone) {
      switch (state) {
        case ParserState.text:
          text();
          break;
        default:
          throw UnimplementedError();
      }
    }
  }

  final StringScanner scanner;

  final List<Node> stack;

  final Fragment root;

  ParserState state;

  Node get current => stack.last;

  void text() {
    final start = scanner.position;
    final data = StringBuffer();

    while (!scanner.isDone) {
      data.writeCharCode(scanner.readChar());
    }

    current.children.add(Text(data.toString(), start: start, end: scanner.position));
  }
}

abstract class Node {
  Node({this.start, this.end}) : children = <Node>[];

  int start;

  int end;

  List<Node> children;
}

class Fragment extends Node {
  Fragment([List<Node> children]) {
    if (children != null) {
      this.children.addAll(children);
    }
  }

  @override
  String toString() {
    return 'Fragment $children';
  }
}

class Text extends Node {
  Text(this.text, {int start, int end}) : super(start: start, end: end);

  final String text;

  @override
  String toString() {
    return "Text '${text.replaceAll("'", r"\'").replaceAll('\r', r'\r').replaceAll('\n', r'\n')}'";
  }
}
