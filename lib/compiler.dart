import 'package:angular_ast/angular_ast.dart';

export 'package:angular_ast/angular_ast.dart';

class Context {}

class Compiler<C> extends TemplateAstVisitor<void, Context> {
  const Compiler();

  @override
  void visitAnnotation(AnnotationAst astNode, [Context context]) {
    throw UnimplementedError('visitAnnotation');
  }

  @override
  void visitAttribute(AttributeAst astNode, [Context context]) {
    throw UnimplementedError('visitAttribute');
  }

  @override
  void visitBanana(BananaAst astNode, [Context context]) {
    throw UnimplementedError('visitBanana');
  }

  @override
  void visitCloseElement(CloseElementAst astNode, [Context context]) {
    throw UnimplementedError('visitCloseElement');
  }

  @override
  void visitComment(CommentAst astNode, [Context context]) {
    throw UnimplementedError('visitComment');
  }

  @override
  void visitEmbeddedContent(EmbeddedContentAst astNode, [Context context]) {
    throw UnimplementedError('visitEmbeddedContent');
  }

  @override
  void visitEvent(EventAst astNode, [Context context]) {
    throw UnimplementedError('visitEvent');
  }

  @override
  void visitExpression(ExpressionAst<Object> astNode, [Context context]) {
    throw UnimplementedError('visitExpression');
  }

  @override
  void visitInterpolation(InterpolationAst astNode, [Context context]) {
    throw UnimplementedError('visitInterpolation');
  }

  @override
  void visitLetBinding(LetBindingAst astNode, [Context context]) {
    throw UnimplementedError('visitLetBinding');
  }

  @override
  void visitProperty(PropertyAst astNode, [Context context]) {
    throw UnimplementedError('visitProperty');
  }

  @override
  void visitReference(ReferenceAst astNode, [Context context]) {
    throw UnimplementedError('visitReference');
  }

  @override
  void visitStar(StarAst astNode, [Context context]) {
    throw UnimplementedError('visitStar');
  }

  @override
  void visitText(TextAst astNode, [Context context]) {
    throw UnimplementedError('visitText');
  }
}
