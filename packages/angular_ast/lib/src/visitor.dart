import 'ast.dart';

export 'visitors/desugar.dart';
export 'visitors/humanizing.dart';
export 'visitors/identity.dart';
export 'visitors/recursive.dart';
export 'visitors/whitespace.dart';

abstract class Visitor<R, C> {
  const Visitor();

  R visitAnnotation(Annotation node, [C? context]);

  R visitAttribute(Attribute node, [C? context]);

  R visitBanana(Banana node, [C? context]);

  R visitCloseElement(CloseElement node, [C? context]);

  R visitComment(Comment node, [C? context]);

  R? visitContainer(Container node, [C? context]) {
    for (var child in node.childNodes) {
      child.accept(this, context);
    }

    return null;
  }

  R visitEmbeddedContent(EmbeddedContent node, [C? context]);

  R? visitEmbeddedTemplate(EmbeddedNode node, [C? context]) {
    for (var attribute in node.attributes) {
      visitAttribute(attribute, context);
    }

    for (var child in node.childNodes) {
      child.accept(this, context);
    }

    for (var property in node.properties) {
      visitProperty(property, context);
    }

    for (var reference in node.references) {
      visitReference(reference, context);
    }

    return null;
  }

  R? visitElement(Element node, [C? context]) {
    for (var attribute in node.attributes) {
      visitAttribute(attribute, context);
    }

    for (var child in node.childNodes) {
      child.accept(this, context);
    }

    for (var event in node.events) {
      visitEvent(event, context);
    }

    for (var property in node.properties) {
      visitProperty(property, context);
    }

    for (var reference in node.references) {
      visitReference(reference, context);
    }

    return null;
  }

  R visitEvent(Event node, [C? context]);

  R visitInterpolation(Interpolation node, [C? context]);

  R visitLetBinding(LetBinding node, [C? context]);

  R visitProperty(Property node, [C? context]);

  R visitReference(Reference node, [C? context]);

  R visitStar(Star node, [C? context]);

  R visitText(Text node, [C? context]);
}
