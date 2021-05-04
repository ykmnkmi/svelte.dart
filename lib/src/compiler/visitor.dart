import 'nodes.dart';

abstract class Visitor<R> {
  R visitComment(Comment node);

  R visitElement(Element node);

  R visitFragment(Fragment node);

  R visitIdentifier(Identifier node);

  R visitText(Text node);
}
