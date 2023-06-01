import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/state/fragment.dart';

final RegExp spaceRe = RegExp('[ \t\r\n]');

final RegExp openCurlRe = RegExp('{\\s*');

final RegExp closeCurlRe = RegExp('\\s*}');

class Parser {
  Parser(this.template, {Object? url})
      : sourceFile = SourceFile.fromString(template, url: url);

  final String template;

  final SourceFile sourceFile;

  int position = 0;

  List<List<String>> endTagsStack = <List<String>>[];

  Match? lastMatch;

  String get rest {
    return template.substring(position);
  }

  bool get isNotDone {
    return position < template.length;
  }

  bool get isDone {
    return position == template.length;
  }

  void allowSpace({bool required = false}) {
    lastMatch = spaceRe.matchAsPrefix(template, position);

    if (lastMatch case var match?) {
      position = match.end;
    } else if (required) {
      error((code: 'missing-whitespace', message: 'Expected whitespace'));
    }
  }

  bool match(Pattern pattern) {
    lastMatch = pattern.matchAsPrefix(template, position);
    return lastMatch != null;
  }

  bool matchFrom(Pattern pattern, int offset) {
    lastMatch = pattern.matchAsPrefix(template, offset);
    return lastMatch != null;
  }

  bool scan(Pattern pattern) {
    lastMatch = pattern.matchAsPrefix(template, position);

    if (lastMatch case var match?) {
      position = match.end;
      return true;
    }

    return false;
  }

  void expect(Pattern pattern, [ErrorCode? errorCode]) {
    lastMatch = pattern.matchAsPrefix(template, position);

    if (lastMatch case var match?) {
      position = match.end;
    } else if (errorCode == null) {
      if (isNotDone) {
        error(unexpectedToken(pattern), position);
      }

      error(unexpectedEOFToken(pattern));
    } else {
      error(errorCode, position);
    }
  }

  Never error(ErrorCode errorCode, [int? position]) {
    var span = sourceFile.span(position ?? this.position, position);
    throw ParseError(errorCode, span);
  }

  Node parse() {
    var nodes = <Node>[];

    while (isNotDone) {
      if (fragment() case var node?) {
        nodes.add(node);
      }
    }

    return Fragment(start: 0, end: template.length, nodes: nodes);
  }
}
