import 'package:string_scanner/string_scanner.dart';

import 'expression.dart';
import 'nodes.dart';
import 'scanner.dart';

enum ParserState {
  mustache,
  text,
}

class Parser {
  Parser();

  Node parse(String template, {Object? sourceUrl, int? position, ParserState state = ParserState.mustache}) {
    final scanner = StringScanner(template.trimRight(), sourceUrl: sourceUrl, position: position);
    return scan(scanner, state: state);
  }

  Node scan(StringScanner scanner, {ParserState state = ParserState.mustache}) {
    final root = Fragment();

    while (!scanner.isDone) {
      switch (state) {
        case ParserState.mustache:
          root.children.add(mustache(scanner));
          break;
        case ParserState.text:
          root.children.add(text(scanner));
          break;
        default:
          throw UnimplementedError();
      }
    }

    return root;
  }

  Mustache mustache(StringScanner scanner) {
    scanner.expect('{');
    scanner.whitespace();
    final expression = ExpressionParser().scan(scanner);
    scanner.whitespace();
    scanner.expect('}');
    return Mustache(expression);
  }

  Text text(StringScanner scanner) {
    final start = scanner.position;
    final content = StringBuffer();

    while (!scanner.isDone && !scanner.matches('{')) {
      content.writeCharCode(scanner.readChar());
    }

    return Text(content.toString());
  }
}
