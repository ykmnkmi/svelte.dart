import 'errors.dart';
import 'nodes.dart';
import 'states.dart';

class LastAutoClosedTag {
  LastAutoClosedTag(this.tag, this.reason, this.depth);

  final String tag;

  final String reason;

  final int depth;
}

class Parser {
  Parser(this.template)
      : stack = <Node>[],
        root = Fragment(),
        index = 0 {
    stack.add(root);

    while (!isDone) {
      if (match('<')) {
        tag(this);
      } else if (match('{')) {
        mustache(this);
      } else {
        text(this);
      }
    }

    if (stack.length > 1) {
      error(code: 'unexpected-eof', message: 'unexpected end of input');
    }
  }

  final String template;

  final List<Node> stack;

  final Fragment root;

  int index;

  LastAutoClosedTag? lastAutoClosedTag;

  @override
  String toString() {
    return 'Parser { ${stack.join(', ')} }';
  }
}

extension ParserMethods on Parser {
  Node get current {
    return stack.last;
  }

  bool get isDone {
    return index >= template.length;
  }

  bool get isEmpty {
    return stack.isEmpty;
  }

  bool get isNotEmpty {
    return stack.isNotEmpty;
  }

  int get length {
    return stack.length;
  }

  String get rest {
    return template.substring(index);
  }

  void add(Node node) {
    current.children.add(node);
  }

  bool eat(String string, {bool required = false, String? message}) {
    if (match(string)) {
      index += string.length;
      return true;
    }

    if (required) {
      error(code: 'unexpected-${isDone ? 'eof' : 'token'}', message: "expected '$string'");
    }

    return false;
  }

  Never error({String? code, String? message}) {
    final start = index - 10 < 0 ? 0 : index - 10;
    final end = index + 10 < template.length ? index + 10 : template.length;
    throw CompileError(code: code, message: message, source: template.substring(start, end), offset: index - start);
  }

  bool match(String string) {
    return template.substring(index, index + string.length) == string;
  }

  String? look(Pattern pattern) {
    final match = pattern.matchAsPrefix(template, index);

    if (match == null) {
      return null;
    }

    return match[0];
  }

  Node pop() {
    return stack.removeLast();
  }

  void push(Node node) {
    stack.add(node);
  }

  String? read(Pattern regExp) {
    final result = look(regExp);

    if (result != null) {
      index += result.length;
    }

    return result;
  }

  String readUntil(Pattern pattern) {
    if (isDone) {
      error(message: 'unexpected end of input');
    }

    final start = index;
    final end = template.indexOf(pattern, index);

    if (end > 0) {
      index = end;
      return template.substring(start, end);
    }

    index = template.length;
    return template.substring(start);
  }

  void whitespace({bool required = false}) {
    const whitespaces = <String>[' ', '\t', '\r', '\n'];

    if (required && whitespaces.contains(template[index])) {
      error(code: 'missing-whitespace', message: 'expected whitespace');
    }

    while (!isDone && whitespaces.contains(template[index])) {
      index += 1;
    }
  }
}

Fragment parse(String template) {
  final parser = Parser(template);
  return parser.root;
}
