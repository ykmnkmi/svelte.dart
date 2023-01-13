import 'package:nutty/src/compiler/parser/parser.dart';
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
    return 'CompileError: $message';
  }
}

extension ScannerErrors on Parser {
  Never duplicateAttribute([int? start, int? end]) {
    error('duplicate-attribute', 'Attributes need to be unique.', start, end);
  }

  Never duplicateElement(String slug, String name, [int? start, int? end]) {
    error('duplicate-$slug', 'A component can only have one <$name> tag.',
        start, end);
  }

  Never invalidElementContent(String slug, String name,
      [int? start, int? end]) {
    error('invalid-$slug-content', '<$name> cannot have children.', start, end);
  }

  Never invalidElementPlacement(String slug, String name,
      [int? start, int? end]) {
    error('invalid-$slug-placement',
        '<$name> tags cannot be inside elements or blocks.', start, end);
  }

  Never invalidTagName([int? start, int? end]) {
    error('invalid-tag-name', 'Expected valid tag name.', start, end);
  }

  Never invalidTagNameSvelteElement(List<String> tags, [int? start, int? end]) {
    error('invalid-tag-name',
        'Valid <svelte:...> tag names are ${tags.join(', ')}.', start, end);
  }

  Never invalidVoidContent(String name, [int? start, int? end]) {
    error(
        'invalid-void-content',
        '<$name> is a void element and cannot have children, or a closing tag.',
        start,
        end);
  }

  Never unclosedComment([int? start, int? end]) {
    error(
        'unclosed-comment', 'Comment was left open, expected -->.', start, end);
  }

  Never unexpectedEOF([int? start, int? end]) {
    error('unexpected-eof', 'Unexpected end of input.', start, end);
  }

  Never unexpectedEOFToken(Pattern token, [int? start, int? end]) {
    error('unexpected-eof', 'Unexpected $token.', start, end);
  }

  Never unexpectedToken(Pattern expected, [int? start, int? end]) {
    error('unexpected-token', 'Expected $expected.', start, end);
  }

  // ...

  Never cssSyntaxError(String message) {
    error('css-syntax-error', message);
  }

  Never duplicateStyle([int? position]) {
    error('duplicate-style',
        'you can only have one top-level <style> tag per component', position);
  }

  Never emptyAttributeShorthand([int? position]) {
    error('empty-attribute-shorthand', 'attribute shorthand cannot be empty',
        position);
  }

  Never emptyDirectiveName(String type, [int? position]) {
    error('empty-directive-name', '$type name cannot be empty', position);
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
        position);
  }

  Never invalidClosingTagUnopened(String name, [int? position]) {
    error('invalid-closing-tag',
        '</$name> attempted to close an element that was not open', position);
  }

  Never invalidClosingTagAutoClosed(String name, String reason,
      [int? position]) {
    error(
        'invalid-closing-tag',
        '</$name> attempted to close <$name> that was already automatically closed by <$reason>',
        position);
  }

  Never invalidDebugArgs([int? position]) {
    error(
        'invalid-debug-args',
        '{@debug ...} arguments must be identifiers, not arbitrary expressions',
        position);
  }

  Never invalidDeclaration() {
    error('invalid-declaration', 'declaration cannot be empty');
  }

  Never invalidDirectiveValue([int? position]) {
    error(
        'invalid-directive-value',
        'directive value must be a Dart expression enclosed in curly braces',
        position);
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

  Never invalidElementDefinition() {
    error('invalid-element-definition', 'Invalid element definition');
  }

  Never invalidRefDirective(String name, [int? position]) {
    error(
        'invalid-ref-directive',
        "The ref directive is no longer supported — use 'bind:this={$name}' instead",
        position);
  }

  Never invalidRefSelector() {
    error('invalid-ref-selector', 'ref selectors are no longer supported');
  }

  Never invalidSelfPlacement([int? position]) {
    error(
        'invalid-self-placement',
        '<piko:self> components can only exist inside {#if} blocks, {#each} blocks, or slots passed to components',
        position);
  }

  Never invalidScriptInstance([int? position]) {
    error(
        'invalid-script',
        'a component can only have one instance-level <script> element',
        position);
  }

  Never invalidScriptModule([int? position]) {
    error(
        'invalid-script',
        'a component can only have one <script context="module"> element',
        position);
  }

  Never invalidScriptContextAttribute([int? position]) {
    error('invalid-script', 'context attribute must be static', position);
  }

  Never invalidScriptContextValue([int? position]) {
    error(
        'invalid-script',
        'if the context attribute is supplied, its value must be "module"',
        position);
  }

  Never invalidThenPlacementUnclosedBlock(String block) {
    error('invalid-then-placement',
        'expected to close $block before seeing {:then} block');
  }

  Never invalidThenPlacementWithoutAwait() {
    error('invalid-then-placement',
        'cannot have an {:then} block outside an {#await ...} block');
  }

  Never missingComponentDefinition([int? position]) {
    error('missing-component-definition',
        "<piko:component> must have a 'this' attribute", position);
  }

  Never missingAttributeValue() {
    error('missing-attribute-value', 'expected value for the attribute');
  }

  Never missingElementDefinition([int? position]) {
    error('missing-element-definition',
        "<piko:element> must have a 'this' attribute", position);
  }

  Never unclosedScript() {
    error('unclosed-script', '<script> must have a closing tag');
  }

  Never unclosedStyle() {
    error('unclosed-style', '<style> must have a closing tag');
  }

  Never unclosedAttributeValue(String token) {
    error('unclosed-attribute-value',
        'expected to close the attribute value with $token');
  }

  Never unexpectedBlockClose() {
    error('unexpected-block-close', 'unexpected block closing tag');
  }

  Never unexpectedTokenDestructure() {
    error('unexpected-token', 'expected identifier or destructure pattern');
  }
}
