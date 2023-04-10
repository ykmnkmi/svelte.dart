import 'package:source_span/source_span.dart' show SourceSpan;

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

({String code, String message}) cssSyntaxError(String message) {
  return (
    code: 'css-syntax-error',
    message: message,
  );
}

const duplicateAttribute = (
  code: 'duplicate-attribute',
  message: 'Attributes need to be unique',
);

({String code, String message}) duplicateElement(String slug, String name) {
  return (
    code: 'duplicate-$slug',
    message: 'A component can only have one <$name> tag'
  );
}

const duplicateStyle = (
  code: 'duplicate-style',
  message: 'You can only have one top-level <style> tag per component'
);

const emptyAttributeShorthand = (
  code: 'empty-attribute-shorthand',
  message: 'Attribute shorthand cannot be empty'
);

({String code, String message}) emptyDirectiveName(String type) {
  return (
    code: 'empty-directive-name',
    message: '$type name cannot be empty',
  );
}

const emptyGlobalSelector = (
  code: 'css-syntax-error',
  message: ':global() must contain a selector',
);

const expectedBlockType = (
  code: 'expected-block-type',
  message: 'Expected if, each or await',
);

const expectedName = (
  code: 'expected-name',
  message: 'Expected name',
);

({String code, String message}) invalidCatchPlacementUnclosedBlock(
  String block,
) {
  return (
    code: 'invalid-catch-placement',
    message: 'Expected to close $block before seeing {:catch} block'
  );
}

const invalidCatchPlacementWithoutAwait = (
  code: 'invalid-catch-placement',
  message: 'Cannot have an {:catch} block outside an {#await ...} block'
);

const invalidComponentDefinition = (
  code: 'invalid-component-definition',
  message: 'invalid component definition'
);

({String code, String message}) invalidClosingTagUnopened(String name) {
  return (
    code: 'invalid-closing-tag',
    message: '</$name> attempted to close an element that was not open',
  );
}

({String code, String message}) invalidClosingTagAutoClosed(
  String name,
  String reason,
) {
  return (
    code: 'invalid-closing-tag',
    message:
        '</$name> attempted to close <$name> that was already automatically closed by <$reason>'
  );
}

const invalidDebugArgs = (
  code: 'invalid-debug-args',
  message:
      '{@debug ...} arguments must be identifiers, not arbitrary expressions'
);

const invalidDeclaration = (
  code: 'invalid-declaration',
  message: 'Declaration cannot be empty',
);

const invalidDirectiveValue = (
  code: 'invalid-directive-value',
  message:
      'Directive value must be a JavaScript expression enclosed in curly braces'
);

const invalidElseIf = (
  code: 'invalid-elseif',
  message: "'elseif' should be 'else if'",
);

const invalidElseIfPlacementOutsideIf = (
  code: 'invalid-elseif-placement',
  message: 'Cannot have an {:else if ...} block outside an {#if ...} block'
);

({String code, String message}) invalidElseifPlacementUnclosedBlock(
  String? block,
) {
  return (
    code: 'invalid-elseif-placement',
    message: 'Expected to close $block before seeing {:else if ...} block'
  );
}

const invalidElsePlacementOutsideIf = (
  code: 'invalid-else-placement',
  message:
      'Cannot have an {:else} block outside an {#if ...} or {#each ...} block'
);

({String code, String message}) invalidElsePlacementUnclosedBlock(
  String? block,
) {
  return (
    code: 'invalid-else-placement',
    message: 'Expected to close $block before seeing {:else} block'
  );
}

({String code, String message}) invalidElementContent(
    String slug, String name) {
  return (
    code: 'invalid-$slug-content',
    message: '<$name> cannot have children',
  );
}

const invalidElementDefinition = (
  code: 'invalid-element-definition',
  message: 'Invalid element definition',
);

({String code, String message}) invalidElementPlacement(
    String slug, String name) {
  return (
    code: 'invalid-$slug-placement',
    message: '<$name> tags cannot be inside elements or blocks'
  );
}

({String code, String message}) invalidLogicBlockPlacement(
  String? location,
  String? name,
) {
  return (
    code: 'invalid-logic-block-placement',
    message: '{#$name} logic block cannot be $location'
  );
}

({String code, String message}) invalidTagPlacement(
  String? location,
  String? name,
) {
  return (
    code: 'invalid-tag-placement',
    message: '{@$name} tag cannot be $location'
  );
}

({String code, String message}) invalidRefDirective(String? name) {
  return (
    code: 'invalid-ref-directive',
    message:
        "The ref directive is no longer supported — use 'bind:this={$name}' instead"
  );
}

const invalidRefSelector = (
  code: 'invalid-ref-selector',
  message: 'ref selectors are no longer supported'
);

const invalidSelfPlacement = (
  code: 'invalid-self-placement',
  message:
      '<svelte:self> components can only exist inside {#if} blocks, {#each} blocks, or slots passed to components'
);

const invalidScriptInstance = (
  code: 'invalid-script',
  message: 'A component can only have one instance-level <script> element'
);

const invalidScriptModule = (
  code: 'invalid-script',
  message: 'A component can only have one <script context="module"> element'
);

const invalidScriptContextAttribute = (
  code: 'invalid-script',
  message: 'context attribute must be static',
);

const invalidScriptContextValue = (
  code: 'invalid-script',
  message: 'If the context attribute is supplied, its value must be "module"'
);

const invalidTagName = (
  code: 'invalid-tag-name',
  message: 'Expected valid tag name',
);

({String code, String message}) invalidTagNameSvelteElement(List<String> tags) {
  return (
    code: 'invalid-tag-name',
    message: 'Valid <svelte:...> tag names are ${tags.join(', ')}'
  );
}

({String code, String message}) invalidThenPlacementUnclosedBlock(
  String block,
) {
  return (
    code: 'invalid-then-placement',
    message: 'Expected to close $block before seeing {:then} block'
  );
}

const invalidThenPlacementWithoutAwait = (
  code: 'invalid-then-placement',
  message: 'Cannot have an {:then} block outside an {#await ...} block'
);

({String code, String message}) invalidVoidContent(String name) {
  return (
    code: 'invalid-void-content',
    message:
        '<$name> is a void element and cannot have children, or a closing tag'
  );
}

const missingComponentDefinition = (
  code: 'missing-component-definition',
  message: "<svelte:component> must have a 'this' attribute"
);

const missingAttributeValue = (
  code: 'missing-attribute-value',
  message: 'Expected value for the attribute'
);

const missingElementDefinition = (
  code: 'missing-element-definition',
  message: "<svelte:element> must have a 'this' attribute"
);

const unclosedScript = (
  code: 'unclosed-script',
  message: '<script> must have a closing tag',
);

const unclosedStyle = (
  code: 'unclosed-style',
  message: '<style> must have a closing tag',
);

const unclosedComment = (
  code: 'unclosed-comment',
  message: 'comment was left open, expected -->',
);

({String code, String message}) unclosedAttributeValue(String token) {
  return (
    code: 'unclosed-attribute-value',
    message: 'Expected to close the attribute value with $token'
  );
}

const unexpectedBlockClose = (
  code: 'unexpected-block-close',
  message: 'Unexpected block closing tag',
);

const unexpectedEOF = (
  code: 'unexpected-eof',
  message: 'Unexpected end of input',
);

({String code, String message}) unexpectedEOFToken(Pattern token) {
  return (
    code: 'unexpected-eof',
    message: 'Unexpected $token',
  );
}

({String code, String message}) unexpectedToken(Pattern token) {
  return (
    code: 'unexpected-token',
    message: 'Expected $token',
  );
}

const unexpectedTokenDestructure = (
  code: 'unexpected-token',
  message: 'Expected identifier or destructure pattern'
);
