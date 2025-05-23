import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/patterns.dart';

import 'state/fragment.dart';

typedef AutoCloseTag = ({String? tag, String reason, int depth});

final RegExp _spaceRe = RegExp('\\s*');

final class Parser {
  Parser({
    required this.template,
    required this.loose,
    this.fileName,
    this.uri,
    this.skipStyle = false,
  }) : length = template.length,
       sourceFile = SourceFile.fromString(template, url: uri),
       root = Root(fragment: Fragment()) {
    stack.add(root);
    fragments.add(root.fragment);

    while (isNotDone) {
      fragment();
    }

    if (stack.length > 1) {
      Node current = this.current;

      if (loose) {
      } else if (current is Element) {
        current.end = current.start + 1;
        elementUnclosed(current, current.name);
      } else {
        current.end = current.start + 1;
        blockUnclosed(current);
      }
    }

    if (root.fragment.children.isNotEmpty) {
      int start = root.fragment.children.first.start;

      while (start < length && spaceRe.hasMatch(template[start])) {
        start += 1;
      }

      int end = root.fragment.children.last.end;

      while (end > 0 && spaceRe.hasMatch(template[end - 1])) {
        end -= 1;
      }

      root.fragment
        ..start = start
        ..end = end;
    }
  }

  final String template;

  final bool loose;

  final String? fileName;

  final Uri? uri;

  final bool skipStyle;

  final int length;

  final SourceFile sourceFile;

  final List<Fragment> fragments = <Fragment>[];

  final List<Node> stack = <Node>[];

  final Root root;

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
    return template.substring(position);
  }

  Never dartError(String message, int offset, int length) {
    dartParseError(message, offset, offset + length);
  }

  bool eat(
    Pattern pattern, [
    bool required = false,
    bool requiredInLoose = true,
  ]) {
    Match? match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
      return true;
    }

    if (required && (!loose || requiredInLoose)) {
      expectedToken(pattern, position);
    }

    return false;
  }

  bool match(Pattern pattern) {
    return pattern.matchAsPrefix(template, position) != null;
  }

  void allowSpace({bool required = false}) {
    Match? match = _spaceRe.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
    }
  }

  void skip(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
    }
  }

  String? read(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, position);

    if (match == null) {
      return null;
    }

    position = match.end;
    return match[0];
  }

  String readUntil(Pattern pattern) {
    if (isDone) {
      if (loose) {
        return '';
      }

      unexpectedEOF(length);
    }

    int found = template.indexOf(pattern, position);

    if (found == -1) {
      int start = position;
      position = length;
      return template.substring(start);
    }

    return template.substring(position, position = found);
  }

  void requireSpace() {
    Match? match = _spaceRe.matchAsPrefix(template, position);

    if (match == null || position == match.end) {
      expectedSpace(position);
    }

    position = match.end;
  }

  void add(Node node) {
    if (fragments.isNotEmpty) {
      fragments.last.children.add(node);
    }
  }

  Node pop() {
    fragments.removeLast();
    return stack.removeLast();
  }
}
