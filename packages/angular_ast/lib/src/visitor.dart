import 'ast.dart';

export 'visitors/desugar.dart';
export 'visitors/humanizing.dart';
export 'visitors/identity.dart';
export 'visitors/recursive.dart';
export 'visitors/whitespace.dart';

/// A visitor for [Template] trees that may process each node.
///
/// An implementation may return element [R], and optionally use [C] as context.
abstract class TemplateVisitor<R, C> {
  const TemplateVisitor();

  /// Visits all annotation ASTs.
  R visitAnnotation(Annotation astNode, [C? context]);

  /// Visits all attribute ASTs.
  R visitAttribute(Attribute astNode, [C? context]);

  /// Visits all banana ASTs.
  ///
  /// **NOTE**: When de-sugared, this will never occur in a template tree.
  R visitBanana(Banana astNode, [C? context]);

  /// Visits all closeElement ASTS.
  R visitCloseElement(CloseElement astNode, [C? context]);

  /// Visits all comment ASTs.
  R visitComment(Comment astNode, [C? context]);

  /// Visits all container ASTs.
  R? visitContainer(Container astNode, [C? context]) {
    astNode.childNodes.forEach((c) => c.accept<R, C?>(this, context));
    return null;
  }

  /// Visits all embedded content ASTs.
  R visitEmbeddedContent(EmbeddedContent astNode, [C? context]);

  /// Visits all embedded template ASTs.
  R? visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [C? context]) {
    astNode
      ..attributes.forEach((a) => visitAttribute(a, context))
      ..childNodes.forEach((c) => c.accept<R, C?>(this, context))
      ..properties.forEach((p) => visitProperty(p, context))
      ..references.forEach((r) => visitReference(r, context));
    return null;
  }

  /// Visits all element ASTs.
  R? visitElement(Element astNode, [C? context]) {
    astNode
      ..attributes.forEach((a) => visitAttribute(a, context))
      ..childNodes.forEach((c) => c.accept<R, C?>(this, context))
      ..events.forEach((e) => visitEvent(e, context))
      ..properties.forEach((p) => visitProperty(p, context))
      ..references.forEach((r) => visitReference(r, context));
    return null;
  }

  /// Visits all event ASTs.
  R visitEvent(Event astNode, [C? context]);

  /// Visits all interpolation ASTs.
  R visitInterpolation(Interpolation astNode, [C? context]);

  /// Visits all let-binding ASTs.
  R visitLetBinding(LetBinding astNode, [C? context]);

  /// Visits all property ASTs.
  R visitProperty(Property astNode, [C? context]);

  /// Visits all reference ASTs.
  R visitReference(Reference astNode, [C? context]);

  /// Visits all star ASTs.
  ///
  /// **NOTE**: When de-sugared, this will never occur in a template tree.
  R visitStar(Star astNode, [C? context]);

  /// Visits all text ASTs.
  R visitText(Text astNode, [C? context]);
}
