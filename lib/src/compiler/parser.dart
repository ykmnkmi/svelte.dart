import 'errors.dart';
import 'nodes.dart';
import 'parser/tag.dart';

Fragment parse(String template) {
  final parser = Parser(template);
  return parser.root;
}

typedef State = String? Function();

class LastAutoClosedTag {
  final String tag;

  final String reason;

  final int depth;

  LastAutoClosedTag(this.tag, this.reason, this.depth);
}

class Parser {
  final String template;

  final List<NodeList> stack;

  final Fragment root;

  int index;

  LastAutoClosedTag? lastAutoClosedTag;

  Parser(this.template)
      : stack = <NodeList>[],
        root = Fragment(),
        index = 0 {
    stack.add(root);

    while (!isDone) {
      if (match('<')) {
        tag();
      } else if (match('{')) {
        mustache();
      } else {
        text();
      }
    }

    if (stack.length > 1) {
      error(code: 'unexpected-eof', message: 'unexpected end of input');
    }
  }

  NodeList get current {
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
      error(code: 'unexpected-${isDone ? 'eof' : 'token'}', message: message ?? "expected '$string'");
    }

    return false;
  }

  Never error({String? code, String? message}) {
    final start = index - 10 < 0 ? 0 : index - 10;
    final end = index + 10 < template.length ? index + 10 : template.length;
    throw CompileError(code: code, message: message, source: template.substring(start, end), offset: index - start);
  }

  void expression() {
    if (!identifier()) {
      error(message: 'primary expression expected');
    }
  }

  void forgetLastAutoClosedTag() {
    if (lastAutoClosedTag != null && stack.length < lastAutoClosedTag!.depth) {
      lastAutoClosedTag = null;
    }
  }

  bool identifier() {
    final re = RegExp(r'[a-zA-Z_$]');
    final buffer = StringBuffer();
    var part = read(re);

    while (part != null) {
      buffer.write(part);
      part = read(re);
    }

    if (buffer.isEmpty) {
      return false;
    }

    add(Identifier('$buffer'));
    return true;
  }

  Never invalidClosingTag(String tag) {
    final message = isLastAutoClosedTag(tag)
        ? '</$tag> attempted to close <$tag> that was already automatically closed by <${lastAutoClosedTag!.reason}>'
        : '</$tag> attempted to close an element that was not open';
    error(code: 'invalid-closing-tag', message: message);
  }

  bool isLastAutoClosedTag(String tag) {
    if (lastAutoClosedTag != null && tag == lastAutoClosedTag!.tag) {
      return true;
    }

    return false;
  }

  String? look(Pattern pattern) {
    final match = pattern.matchAsPrefix(template, index);

    if (match == null) {
      return null;
    }

    return match[0];
  }

  bool match(Pattern pattern) {
    if (pattern is String) {
      return template.substring(index, index + pattern.length) == pattern;
    }

    return pattern.matchAsPrefix(template, index) != null;
  }

  void mustache() {
    eat('{', required: true);
    whitespace();
    expression();
    whitespace();
    eat('}', required: true);
  }

  void pop() {
    stack.removeLast();
  }

  void push([NodeList? nodeList]) {
    stack.add(nodeList ?? NodeList());
  }

  String? read(Pattern regExp) {
    final result = look(regExp);

    if (result != null) {
      index += result.length;
    }

    return result;
  }

  void readSequence(bool Function(Parser parser) done) {
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        add(Text('$buffer'));
        buffer.clear();
      }
    }

    push();

    while (!isDone) {
      if (done(this)) {
        flush();
        return;
      } else if (eat('{')) {
        flush();
        whitespace();
        expression();
        whitespace();
        eat('}', required: true);
      } else {
        buffer.write(template[index++]);
      }
    }

    error(code: 'unexpected-eof', message: 'unexpected end of input');
  }

  String readTagName() {
    final name = readUntil(RegExp('(\\s|\\/|>)'));

    if (name.isEmpty) {
      return 'fragment';
    }

    if (!RegExp(r'^\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\-]*').hasMatch(name)) {
      error(code: 'invalid-tag-name', message: 'expected valid tag name, got $name');
    }

    return name;
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

  void tag() {
    eat('<', required: true);

    var parent = current;

    if (eat('!--')) {
      readUntil('-->');
      eat('-->', required: true, message: 'comment was left open, expected -->');
      return;
    }

    final isClosingTag = eat('/');
    final name = readTagName();
    final element = Element(name);

    whitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        error(code: 'invalid-void-content', message: '<$name> is a void element and cannot have children, or a closing tag');
      }

      eat('>', required: true);

      while (parent is! Element || parent.tag != name) {
        if (parent is! Element) {
          invalidClosingTag(name);
        }

        pop();
        parent = current;
      }

      pop();
      forgetLastAutoClosedTag();
      return;
    } else if (parent is Element && closingTagOmitted(parent.tag, name)) {
      pop();
      lastAutoClosedTag = LastAutoClosedTag(parent.tag, name, length);
    }

    add(element);
    eat('/');
    eat('>', required: true);

    if (name == 'textarea') {
      push(element);
      readSequence((Parser parser) => match('</textarea>'));
      pop();
      read('</textarea>');
    } else if (name == 'script' || name == 'style') {
      element.children.add(Text(readUntil(RegExp('</$name>'))));
      eat('</$name>', required: true);
    } else {
      push(element);
    }
  }

  void text() {
    final start = index;

    while (!isDone && !match('{') && !match('<')) {
      index += 1;
    }

    add(Text(template.substring(start, index)));
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
