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

abstract base class ThrowingVisitor<C, R> implements Visitor<C, R> {
  @override
  R visitAnimationDirective(AnimationDirective node, C context) {
    throw UnimplementedError('visitAnimationDirective');
  }

  @override
  R visitAttribute(Attribute attribute, C context) {
    throw UnimplementedError('visitAttribute');
  }

  @override
  R visitAwaitBlock(AwaitBlock awaitBlock, C context) {
    throw UnimplementedError('visitAwaitBlock');
  }

  @override
  R visitBindDirective(BindDirective node, C context) {
    throw UnimplementedError('visitBindDirective');
  }

  @override
  R visitClassDirective(ClassDirective node, C context) {
    throw UnimplementedError('visitClassDirective');
  }

  @override
  R visitComment(Comment commentTag, C context) {
    throw UnimplementedError('visitComment');
  }

  @override
  R visitComponent(Component node, C context) {
    throw UnimplementedError('visitComponent');
  }

  @override
  R visitDebugTag(DebugTag node, C context) {
    throw UnimplementedError('visitDebugTag');
  }

  @override
  R visitEachBlock(EachBlock eachBlock, C context) {
    throw UnimplementedError('visitEachBlock');
  }

  @override
  R visitExpressionTag(ExpressionTag node, C context) {
    throw UnimplementedError('visitExpressionTag');
  }

  @override
  R visitFinalTag(FinalTag node, C context) {
    throw UnimplementedError('visitFinalTag');
  }

  @override
  R visitFragment(Fragment node, C context) {
    throw UnimplementedError('visitFragment');
  }

  @override
  R visitHtmlTag(HtmlTag node, C context) {
    throw UnimplementedError('visitHtmlTag');
  }

  @override
  R visitIfBlock(IfBlock ifBlock, C context) {
    throw UnimplementedError('visitIfBlock');
  }

  @override
  R visitInstanceScript(InstanceScript script, C context) {
    throw UnimplementedError('visitInstanceScript');
  }

  @override
  R visitKeyBlock(KeyBlock keyBlock, C context) {
    throw UnimplementedError('visitKeyBlock');
  }

  @override
  R visitLetDirective(LetDirective node, C context) {
    throw UnimplementedError('visitLetDirective');
  }

  @override
  R visitModuleScript(ModuleScript script, C context) {
    throw UnimplementedError('visitModuleScript');
  }

  @override
  R visitOnDirective(OnDirective node, C context) {
    throw UnimplementedError('visitOnDirective');
  }

  @override
  R visitOptions(Options node, C context) {
    throw UnimplementedError('visitOptions');
  }

  @override
  R visitRegularElement(RegularElement node, C context) {
    throw UnimplementedError('visitRegularElement');
  }

  @override
  R visitRenderTag(RenderTag node, C context) {
    throw UnimplementedError('visitRenderTag');
  }

  @override
  R visitRoot(Root node, C context) {
    throw UnimplementedError('visitRoot');
  }

  @override
  R visitScriptBody(ScriptContent scriptBody, C context) {
    throw UnimplementedError('visitScriptBody');
  }

  @override
  R visitSlotElement(SlotElement node, C context) {
    throw UnimplementedError('visitSlotElement');
  }

  @override
  R visitSnippetBlock(SnippetBlock snippetBlock, C context) {
    throw UnimplementedError('visitSnippetBlock');
  }

  @override
  R visitSpreadAttribute(SpreadAttribute spreadAttribute, C context) {
    throw UnimplementedError('visitSpreadAttribute');
  }

  @override
  R visitStyle(Style style, C context) {
    throw UnimplementedError('visitStyle');
  }

  @override
  R visitStyleBody(StyleBody styleBody, C context) {
    throw UnimplementedError('visitStyleBody');
  }

  @override
  R visitStyleDirective(StyleDirective node, C context) {
    throw UnimplementedError('visitStyleDirective');
  }

  @override
  R visitSvelteBody(SvelteBody svelteBody, C context) {
    throw UnimplementedError('visitSvelteBody');
  }

  @override
  R visitSvelteBoundary(SvelteBoundary svelteBoundary, C context) {
    throw UnimplementedError('visitSvelteBoundary');
  }

  @override
  R visitSvelteComponent(SvelteComponent svelteBody, C context) {
    throw UnimplementedError('visitSvelteComponent');
  }

  @override
  R visitSvelteDocument(SvelteDocument svelteDocument, C context) {
    throw UnimplementedError('visitSvelteDocument');
  }

  @override
  R visitSvelteElement(SvelteElement svelteElement, C context) {
    throw UnimplementedError('visitSvelteElement');
  }

  @override
  R visitSvelteFragment(SvelteFragment svelteFragment, C context) {
    throw UnimplementedError('visitSvelteFragment');
  }

  @override
  R visitSvelteHead(SvelteHead svelteHead, C context) {
    throw UnimplementedError('visitSvelteHead');
  }

  @override
  R visitSvelteOptions(SvelteOptions svelteOptions, C context) {
    throw UnimplementedError('visitSvelteOptions');
  }

  @override
  R visitSvelteSelf(SvelteSelf svelteSelf, C context) {
    throw UnimplementedError('visitSvelteSelf');
  }

  @override
  R visitSvelteWindow(SvelteWindow svelteWindow, C context) {
    throw UnimplementedError('visitSvelteWindow');
  }

  @override
  R visitText(Text node, C context) {
    throw UnimplementedError('visitText');
  }

  @override
  R visitTitleElement(TitleElement node, C context) {
    throw UnimplementedError('visitTitleElement');
  }

  @override
  R visitTransitionDirective(TransitionDirective node, C context) {
    throw UnimplementedError('visitTransitionDirective');
  }

  @override
  R visitUseDirective(UseDirective node, C context) {
    throw UnimplementedError('visitUseDirective');
  }
}
