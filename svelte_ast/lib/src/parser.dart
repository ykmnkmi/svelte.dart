import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/patterns.dart';

import 'state/fragment.dart';

typedef AutoCloseTag = ({String? tag, String reason, int depth});

final RegExp _spaceRe = RegExp('[ \t\r\n]*');

final class Parser {
  Parser({
    required this.string,
    this.fileName,
    this.uri,
    this.skipStyle = false,
  }) : length = string.length,
       sourceFile = SourceFile.fromString(string, url: uri) {
    stack.add(html);

    while (isNotDone) {
      fragment();
    }

    if (stack.length > 1) {
      Node current = this.current;
      String type, slug;

      if (current is Element) {
        type = '<${current.name}>';
        slug = 'element';
      } else {
        type = 'Block';
        slug = 'block';
      }

      error((
        code: 'unclosed-$slug',
        message: '$type was left open',
      ), current.start);
    }

    if (html.children.isNotEmpty) {
      int start = html.children.first.start;

      while (start < length && spaceRe.hasMatch(string[start])) {
        start += 1;
      }

      int end = html.children.last.end;

      while (end > 0 && spaceRe.hasMatch(string[end - 1])) {
        end -= 1;
      }

      html.start = start;
      html.end = end;
    }
  }

  final String string;

  final String? fileName;

  final Uri? uri;

  final bool skipStyle;

  final int length;

  final SourceFile sourceFile;

  final Fragment html = Fragment(children: <Node>[]);

  final List<Script> scripts = <Script>[];

  final List<Style> styles = <Style>[];

  final List<Node> stack = <Node>[];

  final Set<String> metaTags = <String>{};

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
    int start = position;

    Match? match = _spaceRe.matchAsPrefix(string, position);

    if (match != null) {
      position = match.end;
    }

    if (required && start == position) {
      error((code: 'missing-whitespace', message: 'Expected whitespace'));
    }
  }

  void skip(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(string, position);

    if (match != null) {
      position = match.end;
    }
  }

  bool match(Pattern pattern) {
    return pattern.matchAsPrefix(string, position) != null;
  }

  bool scan(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(string, position);

    if (match == null) {
      return false;
    }

    position = match.end;
    return true;
  }

  String? read(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(string, position);

    if (match == null) {
      return null;
    }

    position = match.end;
    return match[0];
  }

  String readUntil(Pattern pattern, [ErrorCode? errorCode]) {
    int found = string.indexOf(pattern, position);

    if (found == -1) {
      if (isNotDone) {
        return string.substring(position, position = string.length);
      }

      if (errorCode != null) {
        error(errorCode);
      }

      error(unexpectedEOF);
    }

    return string.substring(position, position = found);
  }

  void expect(Pattern pattern, [ErrorCode? errorCode]) {
    Match? match = pattern.matchAsPrefix(string, position);

    if (match == null) {
      if (errorCode != null) {
        error(errorCode, position);
      }

      if (isNotDone) {
        error(unexpectedToken(pattern), position);
      }

      error(unexpectedEOFToken(pattern));
    }

    position = match.end;
  }

  Never dartError(String message, int offset, int length) {
    error((code: 'parse-error', message: message), offset, offset + length);
  }

  Never error(ErrorCode errorCode, [int? position, int? end]) {
    position ??= this.position;
    end ??= position;

    SourceSpan span = sourceFile.span(position, end);
    throw ParseError(errorCode, span);
  }
}
