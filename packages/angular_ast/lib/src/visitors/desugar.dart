import '../ast.dart';
import '../expression/micro.dart';
import '../visitor.dart';

class DesugarVisitor extends IdentityVisitor<void> implements Visitor<Node, void> {
  const DesugarVisitor();

  @override
  Node visitContainer(Container node, [void _]) {
    visitChildren(node);

    if (node.stars.isNotEmpty) {
      return desugarStar(node, node.stars);
    }

    return node;
  }

  @override
  Node visitElement(Element node, [void _]) {
    visitChildren(node);

    if (node.bananas.isNotEmpty) {
      desugarBananas(node);
    }

    if (node.stars.isNotEmpty) {
      return desugarStar(node, node.stars);
    }

    return node;
  }

  void visitChildren(Node node) {
    if (node.childNodes.isEmpty) {
      return;
    }

    var newChildren = <Standalone>[];

    for (var child in node.childNodes) {
      newChildren.add(child.accept(this) as Standalone);
    }

    node.childNodes.clear();
    node.childNodes.addAll(newChildren);
  }

  @override
  Node visitEmbeddedContent(EmbeddedContent node, [void _]) {
    return node;
  }

  @override
  Node visitEmbeddedTemplate(EmbeddedNode node, [void _]) {
    visitChildren(node);
    return node;
  }

  void desugarBananas(Element node) {
    for (var banana in node.bananas) {
      if (banana.value == null) {
        continue;
      }

      node
        ..events.add(Event.from(banana, '${banana.name}Change', '${banana.value} = \$event'))
        ..properties.add(Property.from(banana, banana.name, banana.value!));
    }

    node.bananas.clear();
  }

  Node desugarStar(Standalone node, List<Star> stars) {
    var starAst = stars[0];
    var origin = starAst;
    var starExpression = starAst.value?.trim();
    var expressionOffset = (starAst as ParsedStar).valueToken?.innerValue?.offset;
    var directiveName = starAst.name;
    EmbeddedNode newAst;
    var attributesToAdd = <Attribute>[];
    var propertiesToAdd = <Property>[];
    var letBindingsToAdd = <LetBinding>[];

    if (isMicroExpression(starExpression)) {
      var micro = parseMicroExpression(directiveName, starExpression, expressionOffset,
          sourceUrl: node.sourceUrl!, origin: origin);
      propertiesToAdd.addAll(micro.properties);
      letBindingsToAdd.addAll(micro.letBindings);

      // If the micro-syntax did not produce a binding to the left-hand side
      // property, add it as an attribute in case a directive selector
      // depends on it.
      if (!propertiesToAdd.any((p) => p.name == directiveName)) {
        attributesToAdd.add(Attribute.from(origin, directiveName));
      }

      newAst = EmbeddedNode.from(origin,
          childNodes: <Standalone>[node],
          attributes: attributesToAdd,
          properties: propertiesToAdd,
          letBindings: letBindingsToAdd);
    } else {
      if (starExpression == null) {
        // In the rare case the *-binding has no RHS expression, add the LHS
        // as an attribute rather than a property. This allows matching a
        // directive with an attribute selector, but no input of the same
        // name.
        attributesToAdd.add(Attribute.from(origin, directiveName));
      } else {
        propertiesToAdd.add(Property.from(origin, directiveName, starExpression));
      }

      newAst = EmbeddedNode.from(origin,
          childNodes: <Standalone>[node], attributes: attributesToAdd, properties: propertiesToAdd);
    }

    stars.clear();
    return newAst;
  }
}
