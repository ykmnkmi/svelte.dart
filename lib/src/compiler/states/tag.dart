part of '../states.dart';

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
  final tag = readTagName(parser);
  final element = Element(tag);
  parser.whitespace();

  if (isClosingTag) {
    if (isVoid(tag)) {
      parser.error(message: '<$tag> is a void element and cannot have children, or a closing tag');
    }

    parser.eat('>', required: true);

    while (parent is! Element || parent.tag != tag) {
      if (parent is! Element) {
        parser.error(message: '</$tag> attempted to close an element that was not open');
      }

      parser.pop();
      parent = parser.current;
    }

    parser.pop();
    return;
  }

  parser.add(element);
  parser.eat('>', required: true);
  parser.push(element);
}

String readTagName(Parser parser) {
  return parser.readUntil(RegExp('(\\s|\\/|>)'));
}
