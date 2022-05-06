import 'dart:math' as math;

import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/state/fragment.dart';
import 'package:source_span/source_span.dart' show SourceFile;

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
        html = Node(type: 'Fragment', children: <Node>[]),
        scripts = <Node>[],
        styles = <Node>[],
        index = 0 {
    stack.add(html);

    while (canParse) {
      fragment();
    }

    var children = html.children;

    if (children != null && children.isNotEmpty) {
      var nonWhitespace = RegExp('\\S+');
      var start = children.first.start ?? 0;
      var index = template.indexOf(nonWhitespace, start);
      start = math.max(start, index);

      var end = children.last.end ?? template.length;
      index = template.lastIndexOf(nonWhitespace, end);

      if (index != -1) {
        end = math.min(index + 1, end);
      }

      html.start = start;
      html.end = end;
    }
  }

  final String template;

  final int length;

  final SourceFile sourceFile;

  final Set<String> metaTags;

  final List<Node> stack;

  final Node html;

  final List<Node> scripts;

  final List<Node> styles;

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

  void allowWhitespace({bool require = false}) {
    var match = RegExp('\\s*').matchAsPrefix(template, index);

    if (match == null) {
      if (require) {
        error('missing-whitespace', 'expected whitespace');
      }

      return;
    }

    index = match.end;
  }

  bool match(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, index);
    return match != null;
  }

  bool scan(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, index);

    if (match == null) {
      return false;
    }

    index = match.end;
    return true;
  }

  void expect(Pattern pattern, {Never Function()? onError}) {
    var match = pattern.matchAsPrefix(template, index);

    if (match == null) {
      if (onError == null) {
        if (canParse) {
          unexpectedToken(pattern, index);
        }

        unexpectedEOFToken(pattern);
      }

      onError();
    }

    index = match.end;
  }

  int readChar() {
    return template.codeUnitAt(index++);
  }

  String? read(Pattern pattern) {
    var match = pattern.matchAsPrefix(template, index);

    if (match == null) {
      return null;
    }

    index = match.end;
    return match[0];
  }

  String? readIdentifier() {
    // TODO: add reserved word checking
    return read(RegExp('[_\$A-Za-z][_\$A-Za-z0-9]*'));
  }

  String readUntil(Pattern pattern, [Never Function()? onError]) {
    var found = template.indexOf(pattern, index);

    if (found == -1) {
      if (canParse) {
        return template.substring(index, index = length);
      }

      if (onError == null) {
        unexpectedEOF();
      }

      onError();
    }

    return template.substring(index, index = found);
  }

  Never error(String code, String message, {int? start, int? end}) {
    throw CompileError(code, message, sourceFile.span(start ?? index, end));
  }
}

AST parse(String template, {Object? sourceUrl}) {
  var parser = Parser(template.trimRight(), sourceUrl: sourceUrl);
  var ast = AST(parser.html);

  var styles = parser.styles;

  if (styles.length > 1) {
    parser.duplicateStyle(styles[1].start);
  } else if (styles.isNotEmpty) {
    ast.style = styles.first;
  }

  var scripts = parser.scripts;

  if (scripts.isNotEmpty) {
    var instances = scripts.where((script) => script.data == 'default').toList();
    var modules = scripts.where((script) => script.data == 'module').toList();

    if (instances.length > 1) {
      parser.invalidScriptInstance(instances[1].start);
    } else if (instances.isNotEmpty) {
      ast.instance = instances.first;
    }

    if (modules.length > 1) {
      parser.invalidScriptModule(modules[1].start);
    } else if (modules.isNotEmpty) {
      ast.module = modules.first;
    }
  }

  return ast;
}
