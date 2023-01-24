import 'package:csslib/parser.dart' show Message, parse;
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

    if (cssMode == CssMode.none) {
      return;
    }

    var prefix = template.substring(0, start).replaceAll(nonNewLineRe, ' ');
    var errors = <Message>[];
    var sheet = parse(prefix + content, errors: errors);

    if (errors.isNotEmpty) {
      var error = errors.first;
      cssSyntaxError(error.message, error.span?.start.offset);
    }

    // TODO(parser): css validation

    styles.add(Style(
      start: offset,
      end: position,
      attributes: attributes,
      sheet: sheet,
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
