import 'package:meta/meta.dart';

import '../ast.dart';
import '../visitor.dart';

/// An [TemplateVisitor] that recursively visits all children of an AST node,
/// in addition to itself.
///
/// Note that methods may modify values.
class RecursiveTemplateAstVisitor<C> implements TemplateVisitor<Template, C?> {
  @literal
  const RecursiveTemplateAstVisitor();

  /// Visits a collection of [Template] nodes, returning all of those that
  /// are not null.
  List<T>? visitAll<T extends Template>(Iterable<T>? astNodes, [C? context]) {
    if (astNodes == null) {
      return null;
    }

    var results = <T>[];

    for (var astNode in astNodes) {
      var value = visit(astNode, context);

      if (value != null) {
        results.add(value);
      }
    }

    return results;
  }

  /// Visits a single [Template] node, capturing the type.
  T? visit<T extends Template>(T? astNode, [C? context]) {
    return astNode?.accept(this, context) as T?;
  }

  @override
  Template visitAnnotation(Annotation astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  Template visitAttribute(Attribute astNode, [C? context]) {
    return Attribute.from(astNode, astNode.name, astNode.value, visitAll(astNode.childNodes, context)!);
  }

  @override
  Template visitBanana(Banana astNode, [C? context]) {
    return astNode;
  }

  @override
  Template visitCloseElement(CloseElement astNode, [C? context]) {
    return astNode;
  }

  @override
  Template visitComment(Comment astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  Template visitContainer(Container astNode, [C? context]) {
    return Container.from(astNode,
        annotations: visitAll(astNode.annotations, context) ?? <Annotation>[],
        childNodes: visitAll(astNode.childNodes, context) ?? <StandaloneTemplate>[],
        stars: visitAll(astNode.stars, context) ?? <Star>[]);
  }

  @override
  Template visitEmbeddedContent(EmbeddedContent astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  Template visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [C? context]) {
    return EmbeddedTemplateAst.from(astNode,
        annotations: visitAll(astNode.annotations, context) ?? <Annotation>[],
        attributes: visitAll(astNode.attributes, context) ?? <Attribute>[],
        childNodes: visitAll(astNode.childNodes, context) ?? <StandaloneTemplate>[],
        events: visitAll(astNode.events, context) ?? <Event>[],
        properties: visitAll(astNode.properties, context) ?? <Property>[],
        references: visitAll(astNode.references, context) ?? <Reference>[],
        letBindings: visitAll(astNode.letBindings, context) ?? <LetBinding>[]);
  }

  @override
  @mustCallSuper
  Template? visitElement(Element astNode, [C? context]) =>
      Element.from(astNode, astNode.name, visit(astNode.closeComplement),
          attributes: visitAll(astNode.attributes, context) ?? <Attribute>[],
          childNodes: visitAll(astNode.childNodes, context) ?? <StandaloneTemplate>[],
          events: visitAll(astNode.events, context) ?? <Event>[],
          properties: visitAll(astNode.properties, context) ?? <Property>[],
          references: visitAll(astNode.references, context) ?? <Reference>[],
          bananas: visitAll(astNode.bananas, context) ?? <Banana>[],
          stars: visitAll(astNode.stars, context) ?? <Star>[],
          annotations: visitAll(astNode.annotations, context) ?? <Annotation>[]);

  @override
  @mustCallSuper
  Template visitEvent(Event astNode, [C? context]) {
    return Event.from(astNode, astNode.name, astNode.value, astNode.reductions);
  }

  @override
  @mustCallSuper
  Template visitInterpolation(Interpolation astNode, [C? context]) {
    return Interpolation.from(astNode, astNode.value);
  }

  @override
  Template visitLetBinding(LetBinding astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  Template visitProperty(Property astNode, [C? context]) {
    return Property.from(astNode, astNode.name, astNode.value, astNode.postfix, astNode.unit);
  }

  @override
  Template visitReference(Reference astNode, [C? context]) {
    return astNode;
  }

  @override
  Template visitStar(Star astNode, [C? context]) {
    return astNode;
  }

  @override
  Template visitText(Text astNode, [C? context]) {
    return astNode;
  }
}
