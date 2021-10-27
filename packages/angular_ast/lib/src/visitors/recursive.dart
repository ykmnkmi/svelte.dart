import 'package:meta/meta.dart' show literal, mustCallSuper;

import '../ast.dart';
import '../visitor.dart';

class RecursiveTemplateAstVisitor<C> implements Visitor<Node, C?> {
  @literal
  const RecursiveTemplateAstVisitor();

  List<T>? visitAll<T extends Node>(Iterable<T>? nodes, [C? context]) {
    if (nodes == null) {
      return null;
    }

    var results = <T>[];

    for (var node in nodes) {
      var value = visit(node, context);

      if (value != null) {
        results.add(value);
      }
    }

    return results;
  }

  T? visit<T extends Node>(T? node, [C? context]) {
    return node?.accept(this, context) as T?;
  }

  @override
  Node visitAnnotation(Annotation node, [C? context]) {
    return node;
  }

  @override
  @mustCallSuper
  Node visitAttribute(Attribute node, [C? context]) {
    return Attribute.from(node, node.name, node.value, visitAll(node.childNodes, context)!);
  }

  @override
  Node visitBanana(Banana node, [C? context]) {
    return node;
  }

  @override
  Node visitCloseElement(CloseElement node, [C? context]) {
    return node;
  }

  @override
  Node visitComment(Comment node, [C? context]) {
    return node;
  }

  @override
  @mustCallSuper
  Node visitContainer(Container node, [C? context]) {
    return Container.from(node,
        annotations: visitAll(node.annotations, context) ?? <Annotation>[],
        childNodes: visitAll(node.childNodes, context) ?? <Standalone>[],
        stars: visitAll(node.stars, context) ?? <Star>[]);
  }

  @override
  Node visitEmbeddedContent(EmbeddedContent node, [C? context]) {
    return node;
  }

  @override
  @mustCallSuper
  Node visitEmbeddedTemplate(EmbeddedNode node, [C? context]) {
    return EmbeddedNode.from(node,
        annotations: visitAll(node.annotations, context) ?? <Annotation>[],
        attributes: visitAll(node.attributes, context) ?? <Attribute>[],
        childNodes: visitAll(node.childNodes, context) ?? <Standalone>[],
        events: visitAll(node.events, context) ?? <Event>[],
        properties: visitAll(node.properties, context) ?? <Property>[],
        references: visitAll(node.references, context) ?? <Reference>[],
        letBindings: visitAll(node.letBindings, context) ?? <LetBinding>[]);
  }

  @override
  @mustCallSuper
  Node? visitElement(Element node, [C? context]) {
    return Element.from(node, node.name, visit(node.closeComplement),
        attributes: visitAll(node.attributes, context) ?? <Attribute>[],
        childNodes: visitAll(node.childNodes, context) ?? <Standalone>[],
        events: visitAll(node.events, context) ?? <Event>[],
        properties: visitAll(node.properties, context) ?? <Property>[],
        references: visitAll(node.references, context) ?? <Reference>[],
        bananas: visitAll(node.bananas, context) ?? <Banana>[],
        stars: visitAll(node.stars, context) ?? <Star>[],
        annotations: visitAll(node.annotations, context) ?? <Annotation>[]);
  }

  @override
  @mustCallSuper
  Node visitEvent(Event node, [C? context]) {
    return Event.from(node, node.name, node.value, node.reductions);
  }

  @override
  @mustCallSuper
  Node visitInterpolation(Interpolation node, [C? context]) {
    return Interpolation.from(node, node.value);
  }

  @override
  Node visitLetBinding(LetBinding node, [C? context]) {
    return node;
  }

  @override
  @mustCallSuper
  Node visitProperty(Property node, [C? context]) {
    return Property.from(node, node.name, node.value, node.postfix, node.unit);
  }

  @override
  Node visitReference(Reference node, [C? context]) {
    return node;
  }

  @override
  Node visitStar(Star node, [C? context]) {
    return node;
  }

  @override
  Node visitText(Text node, [C? context]) {
    return node;
  }
}
