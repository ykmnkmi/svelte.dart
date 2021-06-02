part of '../parser.dart';

extension TextParser on Parser {
  Text? text() {
    final start = index;

    while (!isDone && !match('{') && !match('<')) {
      index += 1;
    }

    if (start != index) {
      return Text(template.substring(start, index));
    }
  }
}
