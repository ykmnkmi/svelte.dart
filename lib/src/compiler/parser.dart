import 'errors.dart';
import 'nodes.dart';

part 'parser/expression.dart';
part 'parser/mustache.dart';
part 'parser/tag.dart';
part 'parser/text.dart';

Library parse(String name, String template) {
  final parser = Parser(template);
  return Library(name, parser.root);
}

class LastAutoClosedTag {
  LastAutoClosedTag(this.tag, this.reason, this.depth);

  final String tag;

  final String reason;

  final int depth;
}

class Parser {
  Parser(this.source)
      : stack = <Fragment>[],
        root = Fragment(),
        index = 0 {
    stack.add(root);

    final hasPiko = eat('<piko>');

    while (!isDone) {
      if (match('<')) {
        tag();
      } else if (match('{')) {
        mustache();
      } else {
        text();
      }
    }

    if (hasPiko) {
      eat('</piko>', required: hasPiko);
    }

    if (stack.length > 1) {
      error(code: 'unexpected-eof', message: 'unexpected end of input');
    }
  }

  final String source;

  final List<Fragment> stack;

  Fragment root;

  int index;

  Fragment get current {
    return stack.last;
  }

  bool get isDone {
    return index >= source.length;
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
    return source.substring(index);
  }

  bool eat(String string, {bool required = false, String? message}) {
    if (match(string)) {
      index += string.length;
      return true;
    }

    if (required) {
      error(code: 'unexpected-${isDone ? 'eof' : 'token'}', message: message ?? "expected '$string'");
    }

    return false;
  }

  Never error({String? code, String? message}) {
    final start = index - 10 < 0 ? 0 : index - 10;
    final end = index + 10 < source.length ? index + 10 : source.length;
    throw CompileError(code: code, message: message, source: source.substring(start, end), offset: index - start);
  }

  String? look(Pattern pattern) {
    final match = pattern.matchAsPrefix(source, index);
    return match?[0];
  }

  bool match(String string) {
    final end = index + string.length;
    return end > source.length ? false : source.substring(index, end) == string;
  }

  bool matchPattern(Pattern pattern) {
    return pattern.matchAsPrefix(source, index) != null;
  }

  void push(Node node, [int? offset]) {
    if (offset == null) {
      current.children.add(node);
      return;
    }

    current.children.insert(current.children.length - 1 - offset, node);
  }

  Node? pop() {
    return current.children.isEmpty ? null : current.children.removeLast();
  }

  String? read(String string) {
    if (match(string)) {
      index += string.length;
      return string;
    }

    return null;
  }

  String? readPattern(Pattern pattern) {
    final result = look(pattern);

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
    final end = source.indexOf(pattern, index);

    if (end > 0) {
      index = end;
      return source.substring(start, end);
    }

    index = source.length;
    return source.substring(start);
  }

  void skip(Pattern? pattern) {
    if (pattern == null) {
      return;
    }

    final result = look(pattern);

    if (result != null) {
      index += result.length;
    }
  }

  void skipUntil(Pattern pattern) {
    if (isDone) {
      error(message: 'unexpected end of input');
    }

    final end = source.indexOf(pattern, index);

    if (end > 0) {
      index = end;
      return;
    }

    index = source.length;
  }

  void whitespace({bool required = false}) {
    const whitespaces = <String>[' ', '\t', '\r', '\n'];

    if (required && whitespaces.contains(source[index])) {
      error(code: 'missing-whitespace', message: 'expected whitespace');
    }

    while (!isDone && whitespaces.contains(source[index])) {
      index += 1;
    }
  }
}
