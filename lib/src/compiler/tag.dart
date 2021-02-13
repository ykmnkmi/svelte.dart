import 'expression.dart';
import 'nodes.dart';
import 'parser.dart';
import 'utils.dart';

const String validTagName = r'^\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\-]*';

void tag(Parser parser) {
  parser.eat('<', required: true);
  var parent = parser.current;

  if (parser.eat('!--')) {
    final data = parser.readUntil('-->');
    parser.eat('-->', required: true, message: 'comment was left open, expected -->');
    parser.add(Comment(data.trim()));
    return;
  }

  final isClosingTag = parser.eat('/');
  final name = parser.readTagName();
  final element = Element(name);
  parser.whitespace();

  if (isClosingTag) {
    if (isVoid(name)) {
      parser.error(code: 'invalid-void-content', message: '<$name> is a void element and cannot have children, or a closing tag');
    }

    parser.eat('>', required: true);

    while (parent is! Element || parent.tag != name) {
      if (parent is! Element) {
        parser.invalidClosingTag(name);
      }

      parser.pop();
      parent = parser.current;
    }

    parser.pop();
    parser.forgetLastAutoClosedTag();
    return;
  } else if (parent is Element && closingTagOmitted(parent.tag, name)) {
    parser.pop();
    parser.lastAutoClosedTag = LastAutoClosedTag(parent.tag, name, parser.length);
  }

  parser.add(element);
  parser.eat('/');
  parser.eat('>', required: true);

  if (name == 'textarea') {
    element.children = parser.readSequence((parser) => parser.match('</textarea>'));
    parser.read('</textarea>');
  } else if (name == 'script' || name == 'style') {
    element.children.add(Text(parser.readUntil(RegExp('</$name>'))));
    parser.eat(RegExp('</$name>'), required: true);
  } else {
    parser.push(element);
  }
}

extension on Parser {
  void forgetLastAutoClosedTag() {
    if (lastAutoClosedTag != null && stack.length < lastAutoClosedTag!.depth) {
      lastAutoClosedTag = null;
    }
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

  List<Node> readSequence(bool Function(Parser parser) done) {
    final chunks = <Node>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        chunks.add(Text(buffer.toString()));
        buffer.clear();
      }
    }

    while (!isDone) {
      if (done(this)) {
        flush();
        return chunks;
      } else if (eat('{')) {
        flush();
        whitespace();
        chunks.add(expression(this));
        whitespace();
        eat('}', required: true);
      } else {
        buffer.write(readChar());
      }
    }

    error(code: 'unexpected-eof', message: 'unexpected end of input');
  }

  String readTagName() {
    final name = readUntil(RegExp('(\\s|\\/|>)'));

    if (!RegExp(validTagName).hasMatch(name)) {
      error(code: 'invalid-tag-name', message: 'expected valid tag name');
    }

    return name;
  }
}
