import 'package:analyzer/dart/ast/ast.dart' show Expression;
import 'package:svelte_ast/svelte_ast.dart';

final class TemplateExpressionWriter implements Visitor<StringBuffer, void> {
  TemplateExpressionWriter();

  int index = 0;

  void writeExpression(StringBuffer buffer, Expression expression) {
    buffer.writeln('    final \$expr${index++} = $expression;');
  }

  @override
  void visitAction(Action node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitAnimation(Animation node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitAttribute(Attribute node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitAttributeShorthand(AttributeShorthand node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitAwaitBlock(AwaitBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitBinding(Binding node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitBody(Body node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitCatchBlock(CatchBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitClassDirective(ClassDirective node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitCommentTag(CommentTag commentTag, StringBuffer context) {}

  @override
  void visitConstTag(ConstTag node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitDebugTag(DebugTag node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitDirective(Directive node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitDocument(Document node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitEachBlock(EachBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitElement(Element node, StringBuffer context) {
    for (var attribute in node.attributes) {
      attribute.accept(this, context);
    }

    for (var child in node.children) {
      child.accept(this, context);
    }
  }

  @override
  void visitElseBlock(ElseBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitEventHandler(EventHandler node, StringBuffer context) {
    if (node.expression case var expression?) {
      writeExpression(context, expression);
    }
  }

  @override
  void visitFragment(Fragment node, StringBuffer context) {
    for (var child in node.children) {
      child.accept(this, context);
    }
  }

  @override
  void visitHead(Head node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitIfBlock(IfBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitInlineComponent(InlineComponent node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitInlineElement(InlineElement node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitKeyBlock(KeyBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitLet(Let node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitMustacheTag(MustacheTag node, StringBuffer context) {
    writeExpression(context, node.expression);
  }

  @override
  void visitOptions(Options node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitPendingBlock(PendingBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitRawMustacheTag(RawMustacheTag node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitRef(Ref node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitScript(Script node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitSlot(Slot node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitSlotTemplate(SlotTemplate node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitSpread(Spread node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitStyle(Style node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitStyleDirective(StyleDirective node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitText(Text node, StringBuffer context) {}

  @override
  void visitThenBlock(ThenBlock node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitTitle(Title node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitTransitionDirective(
      TransitionDirective node, StringBuffer context) {
    throw UnimplementedError();
  }

  @override
  void visitWindow(Window node, StringBuffer context) {
    throw UnimplementedError();
  }
}
