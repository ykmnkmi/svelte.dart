import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart' as css;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';

extension StyleParser on Parser {
  Style readStyle(int start, List<AttributeNode> attributes) {
    int contentStart = position;
    String content = readUntil(closingStyleTagRe);

    if (isDone) {
      elementUnclosed('style', length);
    }

    int contentEnd = position;
    expect(closingStyleTagRe);

    css.StyleSheet sheet = css.parse(content);

    return Style(
      start: start,
      end: position,
      content: StyleBody(
        start: contentStart,
        end: contentEnd,
        content: content,
      ),
      children: sheet.topLevels,
    );
  }
}
