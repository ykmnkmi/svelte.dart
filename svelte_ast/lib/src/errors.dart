import 'package:source_span/source_span.dart';

class ParseError extends Error {
  ParseError(this.errorCode, this.span);

  final ErrorCode errorCode;

  final SourceSpan span;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'code': errorCode.code,
      'message': errorCode.message,
      'line': span.start.line + 1,
      'column': span.start.column,
      'offset': span.start.offset,
    };
  }

  @override
  String toString() {
    return 'ParseError: ${errorCode.message}';
  }
}

typedef ErrorCode = ({String code, String message});

const ErrorCode invalidConstArgs = (
  code: 'invalid-const-args',
  message: '{@const ...} must be an assignment',
);

ErrorCode cssSyntaxError(String message) {
  return (code: 'css-syntax-error', message: message);
}

const ErrorCode duplicateAttribute = (
  code: 'duplicate-attribute',
  message: 'Attributes need to be unique',
);

ErrorCode duplicateElement(String slug, String name) {
  return (
    code: 'duplicate-$slug',
    message: 'A component can only have one <$name> tag',
  );
}

const ErrorCode duplicateStyle = (
  code: 'duplicate-style',
  message: 'You can only have one top-level <style> tag per component',
);

const ErrorCode emptyAttributeShorthand = (
  code: 'empty-attribute-shorthand',
  message: 'Attribute shorthand cannot be empty',
);

ErrorCode emptyDirectiveName(String type) {
  return (code: 'empty-directive-name', message: '$type name cannot be empty');
}

const ErrorCode emptyGlobalSelector = (
  code: 'css-syntax-error',
  message: ':global() must contain a selector',
);

const ErrorCode expectedBlockType = (
  code: 'expected-block-type',
  message: 'Expected if, each await or key',
);

const ErrorCode expectedName = (
  code: 'expected-name',
  message: 'Expected name',
);

ErrorCode invalidCatchPlacementUnclosedBlock(String block) {
  return (
    code: 'invalid-catch-placement',
    message: 'Expected to close $block before seeing {:catch} block',
  );
}

const ErrorCode invalidCatchPlacementWithoutAwait = (
  code: 'invalid-catch-placement',
  message: 'Cannot have an {:catch} block outside an {#await ...} block',
);

const ErrorCode invalidComponentDefinition = (
  code: 'invalid-component-definition',
  message: 'invalid component definition',
);

ErrorCode invalidClosingTagUnopened(String name) {
  return (
    code: 'invalid-closing-tag',
    message: '</$name> attempted to close an element that was not open',
  );
}

ErrorCode invalidClosingTagAutoClosed(String name, String reason) {
  return (
    code: 'invalid-closing-tag',
    message:
        '</$name> attempted to close <$name> that was already '
        'automatically closed by <$reason>',
  );
}

const ErrorCode invalidDebugArgs = (
  code: 'invalid-debug-args',
  message: '{@debug ...} arguments must be identifiers',
);

const ErrorCode invalidDeclaration = (
  code: 'invalid-declaration',
  message: 'Declaration cannot be empty',
);

const ErrorCode invalidDirectiveValue = (
  code: 'invalid-directive-value',
  message:
      'Directive value must be a JavaScript expression enclosed in curly '
      'braces',
);

const ErrorCode invalidElseIf = (
  code: 'invalid-elseif',
  message: "'elseif' should be 'else if'",
);

const ErrorCode invalidElseIfPlacementOutsideIf = (
  code: 'invalid-elseif-placement',
  message: 'Cannot have an {:else if ...} block outside an {#if ...} block',
);

ErrorCode invalidElseifPlacementUnclosedBlock(String? block) {
  return (
    code: 'invalid-elseif-placement',
    message: 'Expected to close $block before seeing {:else if ...} block',
  );
}

const ErrorCode invalidElsePlacementOutsideIf = (
  code: 'invalid-else-placement',
  message:
      'Cannot have an {:else} block outside an {#if ...} or {#each ...} block',
);

ErrorCode invalidElsePlacementUnclosedBlock(String? block) {
  return (
    code: 'invalid-else-placement',
    message: 'Expected to close $block before seeing {:else} block',
  );
}

ErrorCode invalidElementContent(String slug, String name) {
  return (
    code: 'invalid-$slug-content',
    message: '<$name> cannot have children',
  );
}

const ErrorCode invalidElementDefinition = (
  code: 'invalid-element-definition',
  message: 'Invalid element definition',
);

ErrorCode invalidElementPlacement(String slug, String name) {
  return (
    code: 'invalid-$slug-placement',
    message: '<$name> tags cannot be inside elements or blocks',
  );
}

ErrorCode invalidLogicBlockPlacement(String? location, String? name) {
  return (
    code: 'invalid-logic-block-placement',
    message: '{#$name} logic block cannot be $location',
  );
}

ErrorCode invalidTagPlacement(String? location, String? name) {
  return (
    code: 'invalid-tag-placement',
    message: '{@$name} tag cannot be $location',
  );
}

ErrorCode invalidRefDirective(String? name) {
  return (
    code: 'invalid-ref-directive',
    message:
        'The ref directive is no longer supported — use '
        "'bind:this={$name}' instead",
  );
}

const ErrorCode invalidRefSelector = (
  code: 'invalid-ref-selector',
  message: 'ref selectors are no longer supported',
);

const ErrorCode invalidSelfPlacement = (
  code: 'invalid-self-placement',
  message:
      '<svelte:self> components can only exist inside {#if} blocks, '
      '{#each} blocks, or slots passed to components',
);

const ErrorCode invalidScriptInstance = (
  code: 'invalid-script',
  message: 'A component can only have one instance-level <script> element',
);

const ErrorCode invalidScriptModule = (
  code: 'invalid-script',
  message: 'A component can only have one <script context="module"> element',
);

const ErrorCode invalidScriptContextAttribute = (
  code: 'invalid-script',
  message: 'context attribute must be static',
);

const ErrorCode invalidScriptContextValue = (
  code: 'invalid-script',
  message: 'If the context attribute is supplied, its value must be "module"',
);

const ErrorCode invalidTagName = (
  code: 'invalid-tag-name',
  message: 'Expected valid tag name',
);

ErrorCode invalidTagNameSvelteElement(List<String> tags) {
  return (
    code: 'invalid-tag-name',
    message: 'Valid <svelte:...> tag names are ${tags.join(', ')}',
  );
}

ErrorCode invalidThenPlacementUnclosedBlock(String block) {
  return (
    code: 'invalid-then-placement',
    message: 'Expected to close $block before seeing {:then} block',
  );
}

const ErrorCode invalidThenPlacementWithoutAwait = (
  code: 'invalid-then-placement',
  message: 'Cannot have an {:then} block outside an {#await ...} block',
);

ErrorCode invalidVoidContent(String name) {
  return (
    code: 'invalid-void-content',
    message:
        '<$name> is a void element and cannot have children, or a closing tag',
  );
}

const ErrorCode missingComponentDefinition = (
  code: 'missing-component-definition',
  message: "<svelte:component> must have a 'this' attribute",
);

const ErrorCode missingAttributeValue = (
  code: 'missing-attribute-value',
  message: 'Expected value for the attribute',
);

const ErrorCode missingElementDefinition = (
  code: 'missing-element-definition',
  message: "<svelte:element> must have a 'this' attribute",
);

const ErrorCode unclosedScript = (
  code: 'unclosed-script',
  message: '<script> must have a closing tag',
);

const ErrorCode unclosedStyle = (
  code: 'unclosed-style',
  message: '<style> must have a closing tag',
);

const ErrorCode unclosedComment = (
  code: 'unclosed-comment',
  message: 'comment was left open, expected -->',
);

ErrorCode unclosedAttributeValue(String token) {
  return (
    code: 'unclosed-attribute-value',
    message: 'Expected to close the attribute value with $token',
  );
}

const ErrorCode unexpectedBlockClose = (
  code: 'unexpected-block-close',
  message: 'Unexpected block closing tag',
);

const ErrorCode unexpectedEOF = (
  code: 'unexpected-eof',
  message: 'Unexpected end of input',
);

ErrorCode unexpectedEOFToken(Pattern token) {
  return (code: 'unexpected-eof', message: 'Unexpected $token');
}

ErrorCode unexpectedToken(Pattern token) {
  return (code: 'unexpected-token', message: 'Expected $token');
}

const ErrorCode unexpectedTokenDestructure = (
  code: 'unexpected-token',
  message: 'Expected identifier or destructure pattern',
);
