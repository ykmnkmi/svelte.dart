import 'package:source_span/source_span.dart' show SourceFile;
import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/state/fragment.dart';

// TODO(parser): add reserved words
const Set<String> reserved = <String>{};

final RegExp spaceRe = RegExp('[ \t\r\n]');

final RegExp nonNewLineRe = RegExp('[^\\n]');

final RegExp openCurlRe = RegExp('{\\s*');

final RegExp closeCurlRe = RegExp('\\s*}');

final RegExp identifierRe = RegExp('[_\$a-zA-Z][_\$a-zA-Z0-9]*');

enum CssMode {
  injected,
  external,
  none,
}

class AutoCloseTag {
  AutoCloseTag(this.tag, this.reason, this.depth);

  String? tag;

  String reason;

  int depth;
}

class Parser {
  Parser(
    String template, {
    Object? sourceUrl,
    CssMode? cssMode,
  })  : template = template.trimRight(),
        sourceFile = SourceFile.fromString(template, url: sourceUrl),
        cssMode = cssMode ?? CssMode.injected {
    stack.add(html);
    html.children = <TemplateNode>[];

    while (isNotDone) {
      fragment();
    }

    if (stack.length > 1) {
      var current = this.current;

      String type, slug;

      if (current.type == 'Element') {
        type = '<${current.name}>';
        slug = 'element';
      } else {
        type = 'Block';
        slug = 'block';
      }

      error(
        (code: 'unclosed-$slug', message: '$type was left open'),
        current.start,
      );
    }

    var children = html.children;

    if (children != null && children.isNotEmpty) {
      var start = children.first.start ?? 0;

      while (spaceRe.hasMatch(template[start])) {
        start += 1;
      }

      html.start = start;

      var end = children.last.end ?? template.length;

      while (spaceRe.hasMatch(template[end - 1])) {
        end -= 1;
      }

      html.end = end;
    }
  }

  final String template;

  final SourceFile sourceFile;

  final CssMode cssMode;

  final TemplateNode html = TemplateNode(type: 'Fragment');

  final List<Script> scripts = <Script>[];

  final List<Style> styles = <Style>[];

  final Set<String> metaTags = <String>{};

  final List<TemplateNode> stack = <TemplateNode>[];

  int position = 0;

  AutoCloseTag? lastAutoCloseTag;

  TemplateNode get current {
    return stack.last;
  }

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

  void expect(Pattern pattern, [({String code, String message})? error]) {
    var match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
      return;
    }

    if (error == null) {
      if (isNotDone) {
        this.error(unexpectedToken(pattern), position);
      }

      this.error(unexpectedEOFToken(pattern));
    }

    this.error(error, position);
  }

  String? read(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
      return match[0];
    }

    return null;
  }

  String? readIdentifier({bool allowReserved = false}) {
    var start = position;
    var match = identifierRe.matchAsPrefix(template, position);

    if (match == null) {
      return null;
    }

    var word = match[0]!;

    if (!allowReserved && reserved.contains(word)) {
      var error = (
        code: 'unexpected-reserved-word',
        message: "'$word' is a reserved word in Dart and cannot be used here",
      );

      this.error(error, start);
    }

    position = match.end;
    return word;
  }

  String readUntil(Pattern pattern, [({String code, String message})? error]) {
    var found = template.indexOf(pattern, position);

    if (found != -1) {
      return template.substring(position, position = found);
    }

    if (isNotDone) {
      return template.substring(position, position = template.length);
    }

    if (error == null) {
      this.error(unexpectedEOF);
    }

    this.error(error);
  }

  Never error(({String code, String message}) error, [int? position]) {
    var span = sourceFile.span(position ?? this.position);
    throw ParseError(error.code, error.message, span);
  }
}
