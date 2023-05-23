import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/state/fragment.dart';

extension FragmentParser on Parser {
  Node body() {
    var start = position;
    var nodes = <Node>[];

    while (isNotDone) {
      if (fragment() case Node node) {
        nodes.add(node);
      }
    }

    return Fragment(start: start, end: position, nodes: nodes);
  }
}
