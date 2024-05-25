import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/patterns.dart';

String trimStart(String string) {
  return string.replaceFirst(startsWithSpacesRe, '');
}

String trimEnd(String string) {
  return string.replaceFirst(endsWithSpacesRe, '');
}

void trimBlock(Node? block, bool before, bool after) {
  if (block == null || block.children.isEmpty) {
    return;
  }

  Node first = block.children.first;

  if (before && first is Text) {
    String data = trimStart(first.data);

    if (data.isEmpty) {
      block.children.removeAt(0);
    } else {
      first.data = data;
    }
  }

  if (after && block.children.isNotEmpty) {
    Node last = block.children.last;

    if (last is Text) {
      String data = trimEnd(last.data);

      if (data.isEmpty) {
        block.children.removeLast();
      } else {
        last.data = data;
      }
    }
  }

  if (block is HasElse) {
    trimBlock(block.elseBlock, before, after);
  }

  if (first is IfBlock && first.elseIf) {
    trimBlock(first, before, after);
  }
}
