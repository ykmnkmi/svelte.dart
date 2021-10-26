import 'package:meta/meta.dart';

import '../ast.dart';
import '../visitor.dart';

/// An [TemplateVisitor] that does nothing but return the AST node back.
class IdentityTemplateAstVisitor<C> implements TemplateVisitor<Template, C?> {
  @literal
  const IdentityTemplateAstVisitor();

  @override
  Template visitAnnotation(Annotation astNode, [_]) {
    return astNode;
  }

  @override
  Template visitAttribute(Attribute astNode, [_]) {
    return astNode;
  }

  @override
  Template visitBanana(Banana astNode, [_]) {
    return astNode;
  }

  @override
  Template visitCloseElement(CloseElement astNode, [_]) {
    return astNode;
  }

  @override
  Template visitComment(Comment astNode, [_]) {
    return astNode;
  }

  @override
  Template visitContainer(Container astNode, [_]) {
    return astNode;
  }

  @override
  Template visitEmbeddedContent(EmbeddedContent astNode, [_]) {
    return astNode;
  }

  @override
  Template visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [_]) {
    return astNode;
  }

  @override
  Template visitElement(Element astNode, [_]) {
    return astNode;
  }

  @override
  Template visitEvent(Event astNode, [_]) {
    return astNode;
  }

  @override
  Template visitInterpolation(Interpolation astNode, [_]) {
    return astNode;
  }

  @override
  Template visitLetBinding(LetBinding astNode, [_]) {
    return astNode;
  }

  @override
  Template visitProperty(Property astNode, [_]) {
    return astNode;
  }

  @override
  Template visitReference(Reference astNode, [_]) {
    return astNode;
  }

  @override
  Template visitStar(Star astNode, [_]) {
    return astNode;
  }

  @override
  Template visitText(Text astNode, [_]) {
    return astNode;
  }
}
