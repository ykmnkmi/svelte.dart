import 'package:meta/meta.dart' show literal;

import '../ast.dart';
import '../visitor.dart';

class IdentityVisitor<C> implements Visitor<Node, C?> {
  @literal
  const IdentityVisitor();

  @override
  Node visitAnnotation(Annotation node, [_]) {
    return node;
  }

  @override
  Node visitAttribute(Attribute node, [_]) {
    return node;
  }

  @override
  Node visitBanana(Banana node, [_]) {
    return node;
  }

  @override
  Node visitCloseElement(CloseElement node, [_]) {
    return node;
  }

  @override
  Node visitComment(Comment node, [_]) {
    return node;
  }

  @override
  Node visitContainer(Container node, [_]) {
    return node;
  }

  @override
  Node visitEmbeddedContent(EmbeddedContent node, [_]) {
    return node;
  }

  @override
  Node visitEmbeddedTemplate(EmbeddedNode node, [_]) {
    return node;
  }

  @override
  Node visitElement(Element node, [_]) {
    return node;
  }

  @override
  Node visitEvent(Event node, [_]) {
    return node;
  }

  @override
  Node visitInterpolation(Interpolation node, [_]) {
    return node;
  }

  @override
  Node visitLetBinding(LetBinding node, [_]) {
    return node;
  }

  @override
  Node visitProperty(Property node, [_]) {
    return node;
  }

  @override
  Node visitReference(Reference node, [_]) {
    return node;
  }

  @override
  Node visitStar(Star node, [_]) {
    return node;
  }

  @override
  Node visitText(Text node, [_]) {
    return node;
  }
}
