part of '../ast.dart';

abstract interface class Visitor<C, R> {
  R visitAttribute(Attribute node, C context);

  R visitAwaitBlock(AwaitBlock node, C context);

  R visitCommentTag(CommentTag commentTag, C context);

  R visitConstTag(ConstTag node, C context);

  R visitDebugTag(DebugTag node, C context);

  R visitEachBlock(EachBlock node, C context);

  R visitElement(Element node, C context);

  R visitElseBlock(ElseBlock node, C context);

  R visitFragment(Fragment node, C context);

  R visitIfBlock(IfBlock node, C context);

  R visitKeyBlock(KeyBlock node, C context);

  R visitMustacheTag(MustacheTag node, C context);

  R visitRawMustacheTag(RawMustacheTag node, C context);

  R visitText(Text node, C context);
}
