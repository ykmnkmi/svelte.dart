import 'nodes.dart';

abstract class Visitor<R, C> {
  R visitFragment(Fragment node, [C context]);

  R visitIdentifier(Identifier node, [C context]);

  R visitMustache(Mustache node, [C context]);

  R visitText(Text node, [C context]);
}
