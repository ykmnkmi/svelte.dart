import 'package:nutty/src/compiler/ast.dart';
import 'package:nutty/src/compiler/parser/errors.dart';
import 'package:nutty/src/compiler/parser/patterns.dart';
import 'package:nutty/src/compiler/parser/state/fragment.dart';
import 'package:source_span/source_span.dart' show SourceFile;

class AutoCloseTag {
  AutoCloseTag(this.tag, this.reason, this.depth);

  String? tag;

  String reason;

  int depth;
}

class Parser {
  Parser(this.template, {Object? sourceUrl})
      : length = template.length,
        sourceFile = SourceFile.fromString(template, url: sourceUrl) {
    var root = Element(start: 0, end: length, type: 'Fragment');
    stack.add(root);

    while (isNotDone) {
      fragment();
    }
  }

  final String template;

  final int length;

  final SourceFile sourceFile;

  final Set<String> metaTags = <String>{};

  final List<Element> stack = <Element>[];

  int position = 0;

  AutoCloseTag? lastAutoCloseTag;

  Element get current {
    return stack.last;
  }

  bool get isNotDone {
    return position < length;
  }

  void allowSpace({bool require = false}) {
    var match = spaceRe.matchAsPrefix(template, position);

    if (match == null) {
      if (require) {
        error('missing-whitespace', 'Expected whitespace.');
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

    if (match == null) {
      return false;
    }

    position = match.end;
    return true;
  }

  void expect(Pattern pattern, [Never Function()? onError]) {
    var match = pattern.matchAsPrefix(template, position);

    if (match == null) {
      if (onError == null) {
        if (isNotDone) {
          unexpectedToken(pattern, position);
        }

        unexpectedEOFToken(pattern);
      }

      onError();
    }

    position = match.end;
  }

  int readChar() {
    return template.codeUnitAt(position++);
  }

  String? read(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, position);

    if (match == null) {
      return null;
    }

    position = match.end;
    return match[0];
  }

  String readUntil(Pattern pattern, {Never Function()? onError}) {
    var found = template.indexOf(pattern, position);

    if (found == -1) {
      if (isNotDone) {
        return template.substring(position, position = length);
      }

      if (onError == null) {
        unexpectedEOF();
      }

      onError();
    }

    return template.substring(position, position = found);
  }

  Never error(String code, String message, [int? start, int? end]) {
    start ??= position;
    throw CompileError(code, message, sourceFile.span(start, end));
  }
}
