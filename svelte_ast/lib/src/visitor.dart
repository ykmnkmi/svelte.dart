import 'package:svelte_ast/src/ast.dart';

abstract interface class Visitor<C, R> {
  R visitAnimationDirective(AnimationDirective node, C context);

  R visitAttribute(Attribute attribute, C context);

  R visitAwaitBlock(AwaitBlock awaitBlock, C context);

  R visitBindDirective(BindDirective node, C context);

  R visitClassDirective(ClassDirective node, C context);

  R visitComment(Comment commentTag, C context);

  R visitComponent(Component node, C context);

  R visitDebugTag(DebugTag node, C context);

  R visitEachBlock(EachBlock eachBlock, C context);

  R visitExpressionTag(ExpressionTag node, C context);

  R visitFinalTag(FinalTag node, C context);

  R visitFragment(Fragment node, C context);

  R visitHtmlTag(HtmlTag node, C context);

  R visitIfBlock(IfBlock ifBlock, C context);

  R visitInstanceScript(InstanceScript script, C context);

  R visitKeyBlock(KeyBlock keyBlock, C context);

  R visitLetDirective(LetDirective node, C context);

  R visitModuleScript(ModuleScript script, C context);

  R visitOnDirective(OnDirective node, C context);

  R visitOptions(Options node, C context);

  R visitRegularElement(RegularElement node, C context);

  R visitRenderTag(RenderTag node, C context);

  R visitRoot(Root node, C context);

  R visitScriptBody(ScriptContent scriptBody, C context);

  R visitSlotElement(SlotElement node, C context);

  R visitSnippetBlock(SnippetBlock snippetBlock, C context);

  R visitSpreadAttribute(SpreadAttribute spreadAttribute, C context);

  R visitStyle(Style style, C context);

  R visitStyleBody(StyleBody styleBody, C context);

  R visitStyleDirective(StyleDirective node, C context);

  R visitSvelteBody(SvelteBody svelteBody, C context);

  R visitSvelteBoundary(SvelteBoundary svelteBoundary, C context);

  R visitSvelteComponent(SvelteComponent svelteBody, C context);

  R visitSvelteDocument(SvelteDocument svelteDocument, C context);

  R visitSvelteElement(SvelteElement svelteElement, C context);

  R visitSvelteFragment(SvelteFragment svelteFragment, C context);

  R visitSvelteHead(SvelteHead svelteHead, C context);

  R visitSvelteOptions(SvelteOptions svelteOptions, C context);

  R visitSvelteSelf(SvelteSelf svelteSelf, C context);

  R visitSvelteWindow(SvelteWindow svelteWindow, C context);

  R visitText(Text node, C context);

  R visitTitleElement(TitleElement node, C context);

  R visitTransitionDirective(TransitionDirective node, C context);

  R visitUseDirective(UseDirective node, C context);
}
