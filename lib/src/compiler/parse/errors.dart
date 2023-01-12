import 'package:nutty/src/compiler/parse/parse.dart';
import 'package:source_span/source_span.dart' show SourceSpan;

class CompileError extends Error {
  CompileError(this.code, this.message, this.span);

  final String code;

  final String message;

  final SourceSpan span;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'code': code,
      'message': message,
      'line': span.start.line + 1,
      'column': span.start.column,
      'offset': span.start.offset,
    };
  }

  @override
  String toString() {
    return 'CompileError: $message\n${span.highlight(color: true)}';
  }
}

extension ParserErrors on Parser {
  Never cssSyntaxError(String message) {
    error(message, 'css-syntax-error');
  }

  Never duplicateAttribute([int? start, int? end]) {
    error('duplicate-attribute', 'attributes need to be unique',
        start: start, end: end);
  }

  Never duplicateElement(String slug, String name, [int? position]) {
    error('duplicate-$slug', 'a component can only have one <$name> tag',
        start: position);
  }

  Never duplicateStyle([int? position]) {
    error('duplicate-style',
        'you can only have one top-level <style> tag per component',
        start: position);
  }

  Never emptyAttributeShorthand([int? position]) {
    error('empty-attribute-shorthand', 'attribute shorthand cannot be empty',
        start: position);
  }

  Never emptyDirectiveName(String type, [int? position]) {
    error('empty-directive-name', '$type name cannot be empty',
        start: position);
  }

  Never emptyGlobalSelector() {
    error('css-syntax-error', ':global() must contain a selector');
  }

  Never expectedBlockType() {
    error('expected-block-type', 'expected if, each or await');
  }

  Never expectedName() {
    error('expected-name', 'expected name');
  }

  Never invalidCatchPlacementUnclosedBlock(String block) {
    error('invalid-catch-placement',
        'expected to close $block before seeing {:catch} block');
  }

  Never invalidCatchPlacementWithoutAwait() {
    error('invalid-catch-placement',
        'cannot have an {:catch} block outside an {#await ...} block');
  }

  Never invalidComponentDefinition([int? position]) {
    error('invalid-component-definition', 'invalid component definition',
        start: position);
  }

  Never invalidClosingTagUnopened(String name, [int? position]) {
    error('invalid-closing-tag',
        '</$name> attempted to close an element that was not open',
        start: position);
  }

  Never invalidClosingTagAutoClosed(String name, String reason,
      [int? position]) {
    error('invalid-closing-tag',
        '</$name> attempted to close <$name> that was already automatically closed by <$reason>',
        start: position);
  }

  Never invalidDebugArgs([int? position]) {
    error('invalid-debug-args',
        '{@debug ...} arguments must be identifiers, not arbitrary expressions',
        start: position);
  }

  Never invalidDeclaration() {
    error('invalid-declaration', 'declaration cannot be empty');
  }

  Never invalidDirectiveValue([int? position]) {
    error('invalid-directive-value',
        'directive value must be a Dart expression enclosed in curly braces',
        start: position);
  }

  Never invalidElseIf() {
    error('invalid-elseif', "'elseif' should be 'else if'");
  }

  Never invalidElseIfPlacementOutsideIf() {
    error('invalid-elseif-placement',
        'cannot have an {:else if ...} block outside an {#if ...} block');
  }

  Never invalidElseIfPlacementUnclosedBlock(String block) {
    error('invalid-elseif-placement',
        'expected to close $block before seeing {:else if ...} block');
  }

  Never invalidElsePlacementOutsideIf() {
    error('invalid-else-placement',
        'cannot have an {:else} block outside an {#if ...} or {#each ...} block');
  }

  Never invalidElsePlacementUnclosedBlock(String block) {
    error('invalid-else-placement',
        'expected to close $block before seeing {:else} block');
  }

  Never invalidElementContent(String slug, String name, [int? position]) {
    error('invalid-$slug-content', '<$name> cannot have children',
        start: position);
  }

  Never invalidElementDefinition() {
    error('invalid-element-definition', 'Invalid element definition');
  }

  Never invalidElementPlacement(String slug, String name, [int? position]) {
    error('invalid-$slug-placement',
        '<$name> tags cannot be inside elements or blocks',
        start: position);
  }

  Never invalidRefDirective(String name, [int? position]) {
    error('invalid-ref-directive',
        "The ref directive is no longer supported — use 'bind:this={$name}' instead",
        start: position);
  }

  Never invalidRefSelector() {
    error('invalid-ref-selector', 'ref selectors are no longer supported');
  }

  Never invalidSelfPlacement([int? position]) {
    error('invalid-self-placement',
        '<piko:self> components can only exist inside {#if} blocks, {#each} blocks, or slots passed to components',
        start: position);
  }

  Never invalidScriptInstance([int? position]) {
    error('invalid-script',
        'a component can only have one instance-level <script> element',
        start: position);
  }

  Never invalidScriptModule([int? position]) {
    error('invalid-script',
        'a component can only have one <script context="module"> element',
        start: position);
  }

  Never invalidScriptContextAttribute([int? position]) {
    error('invalid-script', 'context attribute must be static',
        start: position);
  }

  Never invalidScriptContextValue([int? position]) {
    error('invalid-script',
        'if the context attribute is supplied, its value must be "module"',
        start: position);
  }

  Never invalidTagName([int? position]) {
    error('invalid-tag-name', 'expected valid tag name', start: position);
  }

  Never invalidThenPlacementUnclosedBlock(String block) {
    error('invalid-then-placement',
        'expected to close $block before seeing {:then} block');
  }

  Never invalidThenPlacementWithoutAwait() {
    error('invalid-then-placement',
        'cannot have an {:then} block outside an {#await ...} block');
  }

  Never invalidVoidContent(String name, [int? position]) {
    error('invalid-void-content',
        '<$name> is a void element and cannot have children, or a closing tag',
        start: position);
  }

  Never missingComponentDefinition([int? position]) {
    error('missing-component-definition',
        "<piko:component> must have a 'this' attribute",
        start: position);
  }

  Never missingAttributeValue() {
    error('missing-attribute-value', 'expected value for the attribute');
  }

  Never missingElementDefinition([int? position]) {
    error('missing-element-definition',
        "<piko:element> must have a 'this' attribute",
        start: position);
  }

  Never unclosedScript() {
    error('unclosed-script', '<script> must have a closing tag');
  }

  Never unclosedStyle() {
    error('unclosed-style', '<style> must have a closing tag');
  }

  Never unclosedComment() {
    error('unclosed-comment', 'comment was left open, expected -->');
  }

  Never unclosedAttributeValue(String token) {
    error('unclosed-attribute-value',
        'expected to close the attribute value with $token');
  }

  Never unexpectedBlockClose() {
    error('unexpected-block-close', 'unexpected block closing tag');
  }

  Never unexpectedEOF() {
    error('unexpected-eof', 'unexpected end of input');
  }

  Never unexpectedEOFToken(Pattern token) {
    error('unexpected-eof', 'unexpected $token');
  }

  Never unexpectedToken(Pattern expected, [int? position]) {
    error('unexpected-token', 'expected $expected', start: position);
  }

  Never unexpectedTokenDestructure() {
    error('unexpected-token', 'expected identifier or destructure pattern');
  }
}
