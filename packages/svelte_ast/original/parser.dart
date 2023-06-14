import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';

import 'state/fragment.dart';

typedef AutoCloseTag = ({String? tag, String reason, int depth});

final RegExp _spaceRe = RegExp('[ \t\r\n]*');

final class Parser {
  Parser(this.string, {this.fileName, this.uri})
      : length = string.length,
        sourceFile = SourceFile.fromString(string, url: uri) {
    while (isNotDone) {
      fragment();
    }
  }

  final String string;

  final String? fileName;

  final Uri? uri;

  final int length;

  final SourceFile sourceFile;

  final Set<String> metaTags = <String>{};

  late final List<Node> stack = <Node>[html];

  late final Fragment html = Fragment(
    start: 0,
    end: length,
    children: <Node>[],
  );

  int position = 0;

  AutoCloseTag? lastAutoCloseTag;

  Node get current {
    return stack.last;
  }

  bool get isDone {
    return position >= length;
  }

  bool get isNotDone {
    return position < length;
  }

  String get rest {
    return string.substring(position);
  }

  void allowSpace({bool required = false}) {
    if (_spaceRe.matchAsPrefix(string, position) case Match match?) {
      position = match.end;
    } else if (required) {
      error((code: 'missing-whitespace', message: 'Expected whitespace'));
    }
  }

  bool match(Pattern pattern) {
    return pattern.matchAsPrefix(string, position) != null;
  }

  bool scan(Pattern pattern) {
    if (pattern.matchAsPrefix(string, position) case Match match?) {
      position = match.end;
      return true;
    }

    return false;
  }

  String? read(Pattern pattern) {
    if (pattern.matchAsPrefix(string, position) case Match match?) {
      position = match.end;
      return match[0];
    }

    return null;
  }

  String readUntil(Pattern pattern, [ErrorCode? errorCode]) {
    if (string.indexOf(pattern, position) case int found when found != -1) {
      return string.substring(position, position = found);
    }

    if (isNotDone) {
      return string.substring(position, position = string.length);
    }

    if (errorCode case ErrorCode errorCode?) {
      error(errorCode);
    }

    error(unexpectedEOF);
  }

  void expect(Pattern pattern, [ErrorCode? errorCode]) {
    if (pattern.matchAsPrefix(string, position) case Match match?) {
      position = match.end;
      return;
    }

    if (errorCode case ErrorCode errorCode?) {
      error(errorCode, position);
    }

    if (isNotDone) {
      error(unexpectedToken(pattern), position);
    }

    error(unexpectedEOFToken(pattern));
  }

  Never error(ErrorCode errorCode, [int? position]) {
    position ??= this.position;
    SourceSpan span = sourceFile.span(position, position);
    throw ParseError(errorCode, span);
  }
}
