import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/reserved.dart';
import 'package:svelte_ast/src/state/fragment.dart';

typedef AutoClosedTag = ({String? tag, String reason, int depth});

final RegExp _identifierRe = RegExp('[_\$A-Za-z][_\$A-Za-z0-9]*');

final class Parser {
  Parser({required this.template, this.fileName, this.uri})
    : length = template.length,
      sourceFile = SourceFile.fromString(template, url: uri),
      root = Root(fragment: Fragment()) {
    stack.add(root);
    fragments.add(root.fragment);

    while (isNotDone) {
      fragment();
    }

    if (stack.length > 1) {
      Node current = this.current;

      if (current is RegularElement) {
        current.end = current.start + 1;
        elementUnclosed(current.name, current.start, current.end);
      } else {
        current.end = current.start + 1;
        blockUnclosed(current.start, current.end);
      }
    }

    if (root.fragment.children.isNotEmpty) {
      root.fragment
        ..start = root.fragment.children.first.start
        ..end = root.fragment.children.last.end;
    }
  }

  final String template;

  final String? fileName;

  final Uri? uri;

  final int length;

  final SourceFile sourceFile;

  final List<Fragment> fragments = <Fragment>[];

  final List<Node> stack = <Node>[];

  final Root root;

  final Set<String> metaTags = <String>{};

  int position = 0;

  AutoClosedTag? lastAutoClosedTag;

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

  void allowSpace() {
    Match? match = spaceStarRe.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
    }
  }

  void expectSpace() {
    Match? match = spacePlusRe.matchAsPrefix(template, position);

    if (match == null) {
      expectedSpace(position);
    }

    position = match.end;
  }

  void skip(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
    }
  }

  bool match(Pattern pattern) {
    return pattern.matchAsPrefix(template, position) != null;
  }

  bool scan(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, position);

    if (match != null) {
      position = match.end;
      return true;
    }

    return false;
  }

  void expect(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, position);

    if (match == null) {
      expectedToken(pattern, position);
    }

    position = match.end;
  }

  String? read(Pattern pattern) {
    Match? match = pattern.matchAsPrefix(template, position);

    if (match == null) {
      return null;
    }

    position = match.end;
    return match[0];
  }

  String? readIdentifier([bool allowReserved = false]) {
    int start = position;
    String? identifier = read(_identifierRe);

    if (!allowReserved && identifier != null && isReserved(identifier)) {
      unexpectedReservedWord(identifier, start);
    }

    return identifier;
  }

  String readUntil(Pattern pattern) {
    if (isDone) {
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

  Never dartError(String message, int offset, [int length = 0]) {
    dartParseError(message, offset, offset + length);
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
}
