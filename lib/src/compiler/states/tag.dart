part of '../states.dart';

void tag(Parser parser) {
  parser.eat('<', required: true);

  // final parent = parser.current;

  if (parser.eat('!--')) {
    final data = parser.readUntil('-->');
    parser.eat('-->', required: true, message: 'comment was left open, expected -->');
    parser.push(Comment(data.trim()));
    return;
  }

  // final isClosingTag = parser.eat('/');

  throw UnimplementedError();
}
