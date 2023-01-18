import 'package:svelte/compiler.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

final RegExp styleEndRe = RegExp('<\\/style\\s*>');

extension StyleParser on Parser {
  void style(int offset, List<Node> attributes) {
    var start = position;
    var content = readUntil(styleEndRe, unclosedStyle);
    expect(styleEndRe, unclosedStyle);

    var end = position;

    // TODO(parser): parse styles

    styles.add(Style(
      start: offset,
      end: position,
      attributes: attributes,
      content: StyleContent(
        start: start,
        end: end,
        styles: content,
      ),
    ));
  }
}

void style(Parser parser, int offset, List<Node> attributes) {
  parser.style(offset, attributes);
}
