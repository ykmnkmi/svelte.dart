import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/patterns.dart';

String trimStart(String string) {
  return string.replaceFirst(startsWithSpaces, '');
}

String trimEnd(String string) {
  return string.replaceFirst(endsWithSpaces, '');
}

void trimBlock(Node? block, bool before, bool after) {
  if (block == null || block.children.isEmpty) {
    return;
  }

  Node first = block.children.first;

  if (first is Text && before) {
    String data = trimStart(first.data);

    if (data.isEmpty) {
      block.children.removeAt(0);
    } else {
      first.data = data;
    }
  }

  Node last = block.children.last;

  if (last is Text && after) {
    last.data = trimEnd(last.data);

    if (last.data.isEmpty) {
      block.children.removeLast();
    }
  }

  if (block is HasElse) {
    trimBlock(block.elseBlock, before, after);
  }

  if (first is IfBlock && first.elseIf) {
    trimBlock(first, before, after);
  }
}
