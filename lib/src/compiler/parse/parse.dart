import 'package:source_span/source_span.dart' show SourceFile;

import '../utils/patterns.dart';
import '../interface.dart';

import 'errors.dart';
import 'state/fragment.dart';

class LastAutoClosedTag {
  LastAutoClosedTag(this.tag, this.reason, this.depth);

  String tag;

  String reason;

  int depth;
}

class Parser {
  Parser(this.template, {Object? sourceUrl})
      : length = template.length,
        sourceFile = SourceFile.fromString(template, url: sourceUrl),
        metaTags = <String>{},
        stack = <Node>[],
        html = Node(type: 'Fragment'),
        index = 0 {
    stack.add(html);

    while (canParse) {
      fragment();
    }
  }

  final String template;

  final int length;

  final SourceFile sourceFile;

  final Set<String> metaTags;

  final List<Node> stack;

  final Node html;

  int index;

  LastAutoClosedTag? lastAutoClosedTag;

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

  void expect(Pattern pattern) {
    if (scan(pattern)) {
      return;
    }

    if (canParse) {
      unexpectedToken(pattern);
    }

    unexpectedEOFToken(pattern);
  }

  int readChar() {
    return template.codeUnitAt(index += 1);
  }

  String? read(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, index);
    if (match == null) return null;
    index = match.end;
    return match[0];
  }

  String readUntil(Pattern pattern) {
    var found = template.indexOf(pattern, index);

    if (found == -1) {
      if (canParse) {
        return template.substring(index, index = length);
      }

      error('unexpected-eof', 'unexpected end of input');
    }

    return template.substring(index, index = found);
  }

  Never error(String code, String message, {int? position, int? end}) {
    throw CompileError(code, message, sourceFile.span(position ?? index, end ?? length));
  }
}

Node parse(String template, {Object? sourceUrl}) {
  var parser = Parser(template, sourceUrl: sourceUrl);
  return parser.html;
}
