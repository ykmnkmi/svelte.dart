part of '../ast.dart';

abstract interface class Visitor<C, R> {
  R visitAction(Action node, C context);

  R visitAnimation(Animation node, C context);

  R visitAttribute(Attribute node, C context);

  R visitAttributeShorthand(AttributeShorthand node, C context);

  R visitAwaitBlock(AwaitBlock node, C context);

  R visitBinding(Binding node, C context);

  R visitBody(Body node, C context);

  R visitCatchBlock(CatchBlock node, C context);

  R visitClassDirective(ClassDirective node, C context);

  R visitCommentTag(CommentTag commentTag, C context);

  R visitConstTag(ConstTag node, C context);

  R visitDebugTag(DebugTag node, C context);

  R visitDirective(Directive node, C context);

  R visitDocument(Document node, C context);

  R visitEachBlock(EachBlock node, C context);

  R visitElement(Element node, C context);

  R visitElseBlock(ElseBlock node, C context);

  R visitEventHandler(EventHandler node, C context);

  R visitFragment(Fragment node, C context);

  R visitHead(Head node, C context);

  R visitIfBlock(IfBlock node, C context);

  R visitInlineComponent(InlineComponent node, C context);

  R visitInlineElement(InlineElement node, C context);

  R visitKeyBlock(KeyBlock node, C context);

  R visitLet(Let node, C context);

  R visitMustacheTag(MustacheTag node, C context);

  R visitOptions(Options node, C context);

  R visitPendingBlock(PendingBlock node, C context);

  R visitRawMustacheTag(RawMustacheTag node, C context);

  R visitRef(Ref node, C context);

  R visitScript(Script node, C context);

  R visitSlot(Slot node, C context);

  R visitSlotTemplate(SlotTemplate node, C context);

  R visitSpread(Spread node, C context);

  R visitStyle(Style node, C context);

  R visitStyleDirective(StyleDirective node, C context);

  R visitText(Text node, C context);

  R visitThenBlock(ThenBlock node, C context);

  R visitTitle(Title node, C context);

  R visitTransitionDirective(TransitionDirective node, C context);

  R visitWindow(Window node, C context);
}
