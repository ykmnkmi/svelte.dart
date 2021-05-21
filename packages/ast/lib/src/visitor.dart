import 'nodes.dart';

abstract class Visitor<R, C> {
  const Visitor();

  R visitAnnotation(Annotation node, [C? context]);

  R visitAttribute(Attribute node, [C? context]);

  // R visitBanana(Banana node, [C? context]);

  // R visitCloseElement(CloseElement node, [C? context]);

  // R visitComment(Comment node, [C? context]);

  // R? visitContainer(Container node, [C? context]) {
  //   node.childNodes.forEach((child) => child.accept<R, C?>(this, context));
  //   return null;
  // }

  // R visitEmbeddedContent(EmbeddedContent node, [C? context]);

  R? visitEmbedded(Embedded node, [C? context]) {
    //   ..attributes.forEach((a) => visitAttribute(a, context))

    for (final child in node.childNodes) {
      child.accept<R, C?>(this, context);
    }

    //   ..properties.forEach((p) => visitProperty(p, context))
    //   ..references.forEach((r) => visitReference(r, context));
    return null;
  }

  // R? visitElement(Element node, [C? context]) {
  //   node
  //     ..attributes.forEach((attribute) => visitAttribute(attribute, context))
  //     ..childNodes.forEach((child) => child.accept<R, C?>(this, context))
  //     ..events.forEach((event) => visitEvent(event, context))
  //     ..properties.forEach((property) => visitProperty(property, context))
  //     ..references.forEach((reference) => visitReference(reference, context));
  //   return null;
  // }

  R visitEvent(Event node, [C? context]);

  // R visitInterpolation(Interpolation node, [C? context]);

  // R visitLetBinding(LetBinding node, [C? context]);

  // R visitProperty(Property node, [C? context]);

  // R visitReference(Reference node, [C? context]);

  // R visitStar(Star node, [C? context]);

  R visitText(Text node, [C? context]);
}
