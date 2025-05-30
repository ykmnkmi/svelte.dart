import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/reserved.dart';
import 'package:svelte_ast/src/state/fragment.dart';

typedef AutoClosedTag = ({String? tag, String reason, int depth});

final RegExp _identifierRe = RegExp('[_\$A-Za-z][_\$A-Za-z0-9]*');

final class Parser {
  Parser({required this.template, this.fileName, this.uri, required this.loose})
    : length = template.length,
      sourceFile = SourceFile.fromString(template, url: uri),
      root = Root(fragment: Fragment(children: <Node>[])) {
    stack.add(root);
    fragments.add(root.fragment);

    while (isNotDone) {
      fragment();
    }

    if (stack.length > 1) {
      Node current = this.current;

      if (loose) {
      } else if (current is RegularElement) {
        current.end = current.start + 1;
        elementUnclosed(current.name, current.start, current.end);
      } else {
        current.end = current.start + 1;
        blockUnclosed(current.start, current.end);
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

  final String? fileName;

  final Uri? uri;

  final bool loose;

  final int length;

  final SourceFile sourceFile;

  final List<Fragment> fragments = <Fragment>[];

  final List<Node> stack = <Node>[];

  final Root root;

  final Set<String> metaTags = <String>{};

  int index = 0;

  AutoClosedTag? lastAutoClosedTag;

  Node get current {
    return stack.last;
  }

  bool get isDone {
    return index >= length;
  }

  bool get isNotDone {
    return index < length;
  }

  String get rest {
    return template.substring(index);
  }

  void allowSpace() {
    Match? match = spaceStarRe.matchAsPrefix(template, index);

    if (match != null) {
      index = match.end;
    }
  }

  void expectSpace() {
    Match? match = spacePlusRe.matchAsPrefix(template, index);

    if (match == null) {
      expectedSpace(index);
    }

    index = match.end;
  }

  bool scan(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, index);

    if (match != null) {
      index = match.end;
      return true;
    }

    return false;
  }

  bool expect(Pattern pattern, [bool requiredInLoose = true]) {
    Match? match = pattern.matchAsPrefix(template, index);

    if (match != null) {
      index = match.end;
      return true;
    }

    if (!loose || requiredInLoose) {
      expectedToken(pattern, index);
    }

    return false;
  }

  bool match(Pattern pattern) {
    return pattern.matchAsPrefix(template, index) != null;
  }

  void skip(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, index);

    if (match != null) {
      index = match.end;
    }
  }

  String? read(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, index);

    if (match == null) {
      return null;
    }

    index = match.end;
    return match[0];
  }

  String? readIdentifier([bool allowReserved = false]) {
    int start = index;
    String? identifier = read(_identifierRe);

    if (!allowReserved && identifier != null && isReserved(identifier)) {
      unexpectedReservedWord(identifier, start);
    }

    return identifier;
  }

  String readUntil(Pattern pattern) {
    if (isDone) {
      if (loose) {
        return '';
      }

      unexpectedEOF(length);
    }

    int found = template.indexOf(pattern, index);

    if (found == -1) {
      int start = index;
      index = length;
      return template.substring(start);
    }

    return template.substring(index, index = found);
  }

  void add(Node node) {
    if (fragments.isNotEmpty) {
      fragments.last.children.add(node);
    }
  }

  Node pop() {
    Fragment fragment = fragments.removeLast();

    if (fragment.children.isNotEmpty) {
      fragment
        ..start = fragment.children.first.start
        ..end = fragment.children.last.end;
    }

    return stack.removeLast();
  }

  Never dartError(String message, int offset, [int length = 0]) {
    dartParseError(message, offset, offset + length);
  }
}
