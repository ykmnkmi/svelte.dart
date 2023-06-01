part of '../ast.dart';

abstract class Visitor<C, R> {
  R visitConstTag(ConstTag node, C context);

  R visitDebugTag(DebugTag node, C context);

  R visitEachBlock(EachBlock node, C context);

  R visitFragment(Fragment node, C context);

  R visitIfBlock(IfBlock node, C context);

  R visitMustacheTag(MustacheTag node, C context);

  R visitRawMustacheTag(RawMustacheTag node, C context);

  R visitText(Text node, C context);
}
