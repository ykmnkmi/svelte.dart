import 'package:csslib/visitor.dart' as css;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';

extension StyleParser on Parser {
  Style readStyle(int start, List<AttributeNode> attributes) {
    int contentStart = index;
    String content = readUntil(closingStyleTagRe);

    if (isDone) {
      elementUnclosed('style', length);
    }

    int contentEnd = index;
    expect(closingStyleTagRe);

    // TODO(ast): translate readBody.

    return Style(
      start: start,
      end: index,
      content: StyleBody(
        start: contentStart,
        end: contentEnd,
        content: content,
      ),
      children: <css.TreeNode>[],
    );
  }
}
