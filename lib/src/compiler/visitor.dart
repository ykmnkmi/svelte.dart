import 'nodes.dart';

abstract class Visitor<C, R> {
  R visitComment(Comment node, [C context]);

  R visitElement(Element node, [C context]);

  R visitFragment(Fragment node, [C context]);

  R visitIdentifier(Identifier node, [C context]);

  R visitText(Text node, [C context]);
}
