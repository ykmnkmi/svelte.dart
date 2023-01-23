import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

final RegExp styleEndRe = RegExp('<\\/style\\s*>');

extension StyleParser on Parser {
  void style(int offset, List<TemplateNode> attributes) {
    var start = position;
    var content = readUntil(styleEndRe, unclosedStyle);
    var end = position;
    expect(styleEndRe, unclosedStyle);

    // TODO(parser): parse css

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

void style(Parser parser, int offset, List<TemplateNode> attributes) {
  parser.style(offset, attributes);
}
