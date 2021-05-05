import '../visitor.dart';
import 'nodes.dart';

abstract class HTMLVisitor<R> extends Visitor<R> {
  R visitComment(Comment node);

  R visitElement(Element node);

  R visitFragment(Fragment node);

  R visitIdentifier(Identifier node);

  R visitText(Text node);
}
