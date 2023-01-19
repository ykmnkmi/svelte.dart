import 'package:source_span/source_span.dart' show SourceSpan;
import 'package:svelte/src/compiler/parser/parser.dart';

class ParseError extends Error {
  ParseError(this.code, this.message, this.span);

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
    return 'ParseError: $message';
  }
}

extension ParserErrors on Parser {
  Never cssSyntaxError(String message) {
    error(
      code: 'css-syntax-error',
      message: message,
    );
  }

  Never duplicateAttribute([int? position]) {
    error(
      code: 'duplicate-attribute',
      message: 'Attributes need to be unique',
      position: position,
    );
  }

  Never duplicateElement(String slug, String name, [int? position]) {
    error(
      code: 'duplicate-$slug',
      message: 'A component can only have one <$name> tag',
      position: position,
    );
  }

  Never duplicateStyle() {
    error(
      code: 'duplicate-style',
      message: 'You can only have one top-level <style> tag per component',
    );
  }

  Never emptyAttributeShorthand([int? position]) {
    error(
      code: 'empty-attribute-shorthand',
      message: 'Attribute shorthand cannot be empty',
      position: position,
    );
  }

  Never emptyDirectiveName(String type, [int? position]) {
    error(
      code: 'empty-directive-name',
      message: '$type name cannot be empty',
      position: position,
    );
  }

  Never emptyGlobalSelector() {
    error(
      code: 'css-syntax-error',
      message: ':global() must contain a selector',
    );
  }

  Never expectedBlockType() {
    error(
      code: 'expected-block-type',
      message: 'Expected if, each or await',
    );
  }

  Never expectedName() {
    error(
      code: 'expected-name',
      message: 'Expected name',
    );
  }

  Never invalidCatchPlacementUnclosedBlock(String block) {
    error(
      code: 'invalid-catch-placement',
      message: 'Expected to close $block before seeing {:catch} block',
    );
  }

  Never invalidCatchPlacementWithoutAwait() {
    error(
      code: 'invalid-catch-placement',
      message: 'Cannot have an {:catch} block outside an {#await ...} block',
    );
  }

  Never invalidComponentDefinition([int? position]) {
    error(
      code: 'invalid-component-definition',
      message: 'invalid component definition',
      position: position,
    );
  }

  Never invalidClosingTagUnopened(String name, [int? position]) {
    error(
      code: 'invalid-closing-tag',
      message: '</$name> attempted to close an element that was not open',
      position: position,
    );
  }

  Never invalidClosingTagAutoClosed(
    String name,
    String reason, [
    int? position,
  ]) {
    error(
      code: 'invalid-closing-tag',
      message:
          '</$name> attempted to close <$name> that was already automatically closed by <$reason>',
      position: position,
    );
  }

  Never invalidDebugArgs([int? position]) {
    error(
      code: 'invalid-debug-args',
      message: ''
          '{@debu ...} arguments must be identifiers, '
          'not arbitrary expressions',
      position: position,
    );
  }

  Never invalidDeclaration() {
    error(
      code: 'invalid-declaration',
      message: 'Declaration cannot be empty',
    );
  }

  Never invalidDirectiveValue([int? position]) {
    error(
      code: 'invalid-directive-value',
      message: ''
          'Directive value must be a Dart expression '
          'enclosed in curly braces',
      position: position,
    );
  }

  Never invalidElseIf() {
    error(
      code: 'invalid-elseif',
      message: "'elseif' should be 'else if'",
    );
  }

  Never invalidElseIfPlacementOutsideIf() {
    error(
      code: 'invalid-elseif-placement',
      message: 'Cannot have an {:else if ...} block outside an {#if ...} block',
    );
  }

  Never invalidElseIfPlacementUnclosedBlock(String block) {
    error(
      code: 'invalid-elseif-placement',
      message: 'Expected to close $block before seeing {:else if ...} block',
    );
  }

  Never invalidElsePlacementOutsideIf() {
    error(
      code: 'invalid-else-placement',
      message: ''
          'Cannot have an {:else} block '
          'outside an {#if ...} or {#each ...} block',
    );
  }

  Never invalidElsePlacementUnclosedBlock(String block) {
    error(
      code: 'invalid-else-placement',
      message: 'Expected to close $block before seeing {:else} block',
    );
  }

  Never invalidElementContent(String slug, String name, [int? position]) {
    error(
      code: 'invalid-$slug-content',
      message: '<$name> cannot have children',
      position: position,
    );
  }

  Never invalidElementDefinition([int? position]) {
    error(
      code: 'invalid-element-definition',
      message: 'Invalid element definition',
      position: position,
    );
  }

  Never invalidElementPlacement(String slug, String name, [int? position]) {
    error(
      code: 'invalid-$slug-placement',
      message: '<$name> tags cannot be inside elements or blocks',
      position: position,
    );
  }

  Never invalidLogicBlockPlacement(
    String location,
    String name, [
    int? position,
  ]) {
    error(
      code: 'invalid-logic-block-placement',
      message: '{#$name} logic block cannot be $location',
      position: position,
    );
  }

  Never invalidTagPlacement(String location, String name, [int? position]) {
    error(
      code: 'invalid-tag-placement',
      message: '{@$name} tag cannot be $location',
      position: position,
    );
  }

  Never invalidRefDirective(String name, [int? position]) {
    error(
      code: 'invalid-ref-directive',
      message: ''
          'The ref directive is no longer supported '
          "— use 'bind:this={$name}' instead",
      position: position,
    );
  }

  Never invalidRefSelector() {
    error(
      code: 'invalid-ref-selector',
      message: 'Ref selectors are no longer supported',
    );
  }

  Never invalidSelfPlacement([int? position]) {
    error(
      code: 'invalid-self-placement',
      message: ''
          '<svelte:self> components can only exist inside {#if} blocks, '
          '{#each} blocks, or slots passed to components',
      position: position,
    );
  }

  Never invalidScriptInstance() {
    error(
      code: 'invalid-script',
      message: 'A component can only have one instance-level <script> element',
    );
  }

  Never invalidScriptModule() {
    error(
      code: 'invalid-script',
      message: ''
          'A component can only have one '
          '<script context="module"> element',
    );
  }

  Never invalidScriptContextAttribute([int? position]) {
    error(
      code: 'invalid-script',
      message: 'Context attribute must be static',
      position: position,
    );
  }

  Never invalidScriptContextValue([int? position]) {
    error(
      code: 'invalid-script',
      message: ''
          'If the context attribute is supplied, '
          'it\'s value must be "module"',
      position: position,
    );
  }

  Never invalidTagName([int? position]) {
    error(
      code: 'invalid-tag-name',
      message: 'Expected valid tag name',
      position: position,
    );
  }

  Never invalidTagNameSvelteElement(List<String> tags, [int? position]) {
    error(
      code: 'invalid-tag-name',
      message: 'Valid <svelte:...> tag names are ${tags.join(', ')}',
      position: position,
    );
  }

  Never invalidThenPlacementUnclosedBlock(String block) {
    error(
      code: 'invalid-then-placement',
      message: 'Expected to close $block before seeing {:then} block',
    );
  }

  Never invalidThenPlacementWithoutAwait() {
    error(
      code: 'invalid-then-placement',
      message: 'Cannot have an {:then} block outside an {#await ...} block',
    );
  }

  Never invalidVoidContent(String name, [int? position]) {
    error(
      code: 'invalid-void-content',
      message: ''
          '<$name> is a void element and cannot have children, '
          'or a closing tag',
      position: position,
    );
  }

  Never missingComponentDefinition([int? position]) {
    error(
      code: 'missing-component-definition',
      message: "<svelte:component> must have a 'this' attribute",
      position: position,
    );
  }

  Never missingAttributeValue() {
    error(
      code: 'missing-attribute-value',
      message: 'Expected value for the attribute',
    );
  }

  Never missingElementDefinition([int? position]) {
    error(
      code: 'missing-element-definition',
      message: "<svelte:element> must have a 'this' attribute",
      position: position,
    );
  }

  Never unclosedScript() {
    error(
      code: 'unclosed-script',
      message: '<script> must have a closing tag',
    );
  }

  Never unclosedStyle() {
    error(
      code: 'unclosed-style',
      message: '<style> must have a closing tag',
    );
  }

  Never unclosedComment() {
    error(
      code: 'unclosed-comment',
      message: 'Comment was left open, expected -->',
    );
  }

  Never unclosedAttributeValue(String token) {
    error(
      code: 'unclosed-attribute-value',
      message: 'Expected to close the attribute value with $token',
    );
  }

  Never unexpectedBlockClose() {
    error(
      code: 'unexpected-block-close',
      message: 'Unexpected block closing tag',
    );
  }

  Never unexpectedEof() {
    error(
      code: 'unexpected-eof',
      message: 'Unexpected end of input',
    );
  }

  Never unexpectedEofToken(Pattern token) {
    error(
      code: 'unexpected-eof',
      message: 'Unexpected $token',
    );
  }

  Never unexpectedToken(Pattern token, [int? position]) {
    error(
      code: 'unexpected-token',
      message: 'Expected $token',
      position: position,
    );
  }

  Never unexpectedTokenDestructure() {
    error(
      code: 'unexpected-token',
      message: 'Expected identifier or destructure pattern',
    );
  }
}
