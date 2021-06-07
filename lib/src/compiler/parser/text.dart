part of '../parser.dart';

extension TextParser on Parser {
  void text() {
    final start = index;

    while (!isDone && !match('{') && !match('<')) {
      index += 1;
    }

    if (start != index) {
      push(Text(source.substring(start, index)));
    }
  }
}
