import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/state/body.dart';

final RegExp spaceRe = RegExp('[ \t\r\n]');

class Parser {
  Parser(this.template, {Object? url})
      : sourceFile = SourceFile.fromString(template, url: url);

  final String template;

  final SourceFile sourceFile;

  int position = 0;

  bool get isNotDone {
    return position < template.length;
  }

  bool get isDone {
    return position == template.length;
  }

  void allowSpace({bool required = false}) {
    var match = spaceRe.matchAsPrefix(template, position);

    if (match == null) {
      if (required) {
        error((code: 'missing-whitespace', message: 'Expected whitespace'));
      }

      return;
    }

    position = match.end;
  }

  bool match(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, position);
    return match != null;
  }

  bool scan(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
      return true;
    }

    return false;
  }

  void expect(Pattern pattern, [ErrorCode? errorCode]) {
    var match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
      return;
    }

    if (errorCode == null) {
      if (isNotDone) {
        error(unexpectedToken(pattern), position);
      }

      error(unexpectedEOFToken(pattern));
    }

    error(errorCode, position);
  }

  Never error(ErrorCode errorCode, [int? position]) {
    var span = sourceFile.span(position ?? this.position);
    throw ParseError(errorCode, span);
  }

  Node parse() {
    return body();
  }
}
