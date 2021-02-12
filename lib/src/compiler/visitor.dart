import 'nodes.dart';

abstract class Visitor<C, R> {
  R visitFragment(Fragment node, [C context]);

  R visitIdentifier(Identifier node, [C context]);

  R visitText(Text node, [C context]);
}
