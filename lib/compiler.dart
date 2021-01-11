import 'package:angular_ast/angular_ast.dart';

export 'package:angular_ast/angular_ast.dart';

class Frame {}

class Compiler extends TemplateAstVisitor<void, Frame> {
  const Compiler();

  @override
  void visitAnnotation(AnnotationAst astNode, [Frame context]) {
    throw UnimplementedError('visitAnnotation');
  }

  @override
  void visitAttribute(AttributeAst astNode, [Frame context]) {
    throw UnimplementedError('visitAttribute');
  }

  @override
  void visitBanana(BananaAst astNode, [Frame context]) {
    throw UnimplementedError('visitBanana');
  }

  @override
  void visitCloseElement(CloseElementAst astNode, [Frame context]) {
    throw UnimplementedError('visitCloseElement');
  }

  @override
  void visitComment(CommentAst astNode, [Frame context]) {
    throw UnimplementedError('visitComment');
  }

  @override
  void visitEmbeddedContent(EmbeddedContentAst astNode, [Frame context]) {
    throw UnimplementedError('visitEmbeddedContent');
  }

  @override
  void visitEvent(EventAst astNode, [Frame context]) {
    throw UnimplementedError('visitEvent');
  }

  @override
  void visitExpression(ExpressionAst<Object> astNode, [Frame context]) {
    throw UnimplementedError('visitExpression');
  }

  @override
  void visitInterpolation(InterpolationAst astNode, [Frame context]) {
    throw UnimplementedError('visitInterpolation');
  }

  @override
  void visitLetBinding(LetBindingAst astNode, [Frame context]) {
    throw UnimplementedError('visitLetBinding');
  }

  @override
  void visitProperty(PropertyAst astNode, [Frame context]) {
    throw UnimplementedError('visitProperty');
  }

  @override
  void visitReference(ReferenceAst astNode, [Frame context]) {
    throw UnimplementedError('visitReference');
  }

  @override
  void visitStar(StarAst astNode, [Frame context]) {
    throw UnimplementedError('visitStar');
  }

  @override
  void visitText(TextAst astNode, [Frame context]) {
    throw UnimplementedError('visitText');
  }
}
