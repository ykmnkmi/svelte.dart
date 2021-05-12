import 'nodes.dart';

void trim(Node node) {
  if (node is NodeList<Node> && node.isNotEmpty) {
    for (var i = 1; i < node.length - 1;) {
      final current = node[i];

      if (current is Text) {
        final previous = node.children[i - 1];

        if (previous is Text) {
          previous.data += current.data;
          node.removeAt(i);
          continue;
        }
      }

      i += 1;
    }

    var first = node.first;

    if (first is Text) {
      first.data = first.data.trimLeft();

      if (first.isEmpty) {
        node.removeAt(0);
      }
    }

    if (node.isNotEmpty) {
      final last = node.last;

      if (last is Text) {
        last.data = last.data.trimRight();

        if (last.isEmpty) {
          node.removeLast();
        }
      }
    }

    for (var i = 0; i < node.length;) {
      final child = node[i];

      if (child is NodeList<Node>) {
        if (child.isEmpty) {
          node.removeAt(i);
          continue;
        } else {
          trim(child);
        }
      }

      i += 1;
    }
  }
}
