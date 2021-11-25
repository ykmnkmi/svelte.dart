import 'package:source_span/source_span.dart' show SourceFile;

import '../utils/patterns.dart';
import '../interface.dart';

import 'errors.dart';
import 'state/fragment.dart';

class Parser {
  Parser(this.template, {Object? sourceUrl})
      : length = template.length,
        sourceFile = SourceFile.fromString(template, url: sourceUrl) {
    stack.add(html);

    while (canParse) {
      fragment();
    }
  }

  final String template;

  final int length;

  final SourceFile sourceFile;

  final List<Node> stack = <Node>[];

  final Fragment html = Fragment();

  int index = 0;

  bool get canParse {
    return index < length;
  }

  String get rest {
    return template.substring(index);
  }

  Node get current {
    return stack.last;
  }

  void allowWhitespace() {
    scan(whitespace);
  }

  bool match(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, index);
    return match != null;
  }

  bool scan(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, index);
    if (match == null) return false;
    index = match.end;
    return true;
  }

  int readChar() {
    return template.codeUnitAt(index += 1);
  }

  String? read(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, index);
    if (match == null) return null;
    index += match.end;
    return match[0];
  }

  void expect(Pattern pattern) {
    if (scan(pattern)) {
      return;
    }

    if (canParse) {
      unexpectedToken(pattern);
    }

    unexpectedEOF(pattern);
  }

  Never error(String code, String message, {int? position, int? end}) {
    throw CompileError(code, message, sourceFile.span(position ?? index, end ?? length));
  }
}

Node parse(String template, {Object? sourceUrl}) {
  var parser = Parser(template, sourceUrl: sourceUrl);
  return parser.html;
}
