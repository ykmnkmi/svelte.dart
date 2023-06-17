import 'package:csslib/parser.dart' show Message, parse;
import 'package:csslib/visitor.dart' as csslib show Visitor;
import 'package:csslib/visitor.dart' show StyleSheet;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';

final RegExp _styleCloseTag = RegExp('<\\/style\\s*>');

extension StyleParser on Parser {
  void readStyle(int start, List<Node> attributes) {
    expect('>');

    int contentStart = position;
    String content = readUntil(_styleCloseTag, unclosedStyle);

    if (isDone) {
      error(unclosedStyle);
    }

    int contentEnd = position;

    if (cssMode == CssMode.none) {
      read(_styleCloseTag);
      return;
    }

    List<Message> errors = <Message>[];
    StyleSheet ast = parse(content, errors: errors);

    if (errors.isNotEmpty) {
      Message first = errors.first;
      error(cssSyntaxError(first.message), first.span?.start.offset);
    }

    ast.visit(const StyleValidator());
    expect(_styleCloseTag);

    styles.add(Style(
      start: start,
      end: position,
      attributes: attributes,
      topLevels: ast.topLevels,
      content: (
        start: contentStart,
        end: contentEnd,
        content: content,
      ),
    ));
  }
}

// TODO(read:style): complete StyleValidator
class StyleValidator extends Object with csslib.Visitor {
  const StyleValidator();
}
