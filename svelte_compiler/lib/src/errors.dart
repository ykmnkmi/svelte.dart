import 'package:source_span/source_span.dart';

typedef ErrorCode = ({String code, String message});

class CompileError extends Error {
  CompileError(this.errorCode, this.span);

  final ErrorCode errorCode;

  final SourceSpan span;

  String message() {
    return span.message(errorCode.message);
  }

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
    return 'CompileError: ${errorCode.message}';
  }
}

ErrorCode invalidBindingElements(String element, String binding) {
  return (
    code: 'invalid-binding',
    message: "'$binding' is not a valid binding on <$element> elements",
  );
}

ErrorCode invalidBindingElementWith(String elements, String binding) {
  return (
    code: 'invalid-binding',
    message: "'$binding' binding can only be used with $elements",
  );
}

ErrorCode invalidBindingOn(String binding, String element, [String post = '']) {
  return (
    code: 'invalid-binding',
    message: "'$binding' is not a valid binding on $element$post",
  );
}

ErrorCode invalidBindingForeign(String binding) {
  return (
    code: 'invalid-binding',
    message: "'$binding' is not a valid binding. Foreign elements only support "
        'bind:this',
  );
}

ErrorCode invalidBindingNoCheckbox(String binding, bool isRadio) {
  String message =
      "'$binding' binding can only be used with <input type=\"checkbox\">";

  if (isRadio) {
    message += ' — for <input type="radio">, use \'group\' binding';
  }

  return (code: 'invalid-binding', message: message);
}

ErrorCode invalidBinding(String binding) {
  return (
    code: 'invalid-binding',
    message: "'$binding' is not a valid binding",
  );
}

ErrorCode invalidBindingWindow(List<String> parts) {
  return (
    code: 'invalid-binding',
    message: 'Bindings on <svelte:window> must be to top-level properties, '
        "e.g. '${parts.last}' rather than '${parts.join('.')}'",
  );
}

const ErrorCode invalidBindingLet = (
  code: 'invalid-binding',
  message: 'Cannot bind to a variable declared with the let: directive',
);

const ErrorCode invalidBindingAwait = (
  code: 'invalid-binding',
  message: 'Cannot bind to a variable declared with {#await ... then} or '
      '{:catch} blocks',
);

const ErrorCode invalidBindingConst = (
  code: 'invalid-binding',
  message: 'Cannot bind to a variable declared with {@const ...}',
);

const ErrorCode invalidBindingWritable = (
  code: 'invalid-binding',
  message: 'Cannot bind to a variable which is not writable',
);

ErrorCode bindingUndeclared(String name) {
  return (
    code: 'binding-undeclared',
    message: '$name is not declared',
  );
}

const ErrorCode invalidType = (
  code: 'invalid-type',
  message: "'type' attribute cannot be dynamic if input uses two-way binding",
);

const ErrorCode missingType = (
  code: 'missing-type',
  message: "'type' attribute must be specified",
);

const ErrorCode dynamicMultipleAttribute = (
  code: 'dynamic-multiple-attribute',
  message: "'multiple' attribute cannot be dynamic "
      'if select uses two-way binding',
);

const ErrorCode missingContentEditableAttribute = (
  code: 'missing-contenteditable-attribute',
  message: "'contenteditable' attribute is required for textContent, innerHTML "
      'and innerText two-way bindings',
);

const ErrorCode dynamicContentEditableAttribute = (
  code: 'dynamic-contenteditable-attribute',
  message: "'contenteditable' attribute cannot be dynamic if element uses "
      'two-way binding',
);

ErrorCode invalidEventModifierCombination(String modifier1, String modifier2) {
  return (
    code: 'invalid-event-modifier',
    message: "The '$modifier1' and '$modifier2' modifiers cannot be used "
        'together',
  );
}

ErrorCode invalidEventModifierLegacy(String modifier) {
  return (
    code: 'invalid-event-modifier',
    message: "The '$modifier' modifier cannot be used in legacy mode",
  );
}

ErrorCode invalidEventModifier(String valid) {
  return (
    code: 'invalid-event-modifier',
    message: 'Valid event modifiers are $valid',
  );
}

const ErrorCode invalidEventModifierComponent = (
  code: 'invalid-event-modifier',
  message: "Event modifiers other than 'once' can only be used on DOM elements",
);

const ErrorCode textareaDuplicateValue = (
  code: 'textarea-duplicate-value',
  message: 'A <textarea> can have either a value attribute or (equivalently) '
      'child content, but not both',
);

ErrorCode illegalAttribute(String name) {
  return (
    code: 'illegal-attribute',
    message: "'$name' is not a valid attribute name",
  );
}

const ErrorCode invalidSlotAttribute = (
  code: 'invalid-slot-attribute',
  message: 'slot attribute cannot have a dynamic value',
);

ErrorCode duplicateSlotAttribute(String name) {
  return (
    code: 'duplicate-slot-attribute',
    message: "Duplicate '$name' slot",
  );
}

const ErrorCode invalidSlottedContent = (
  code: 'invalid-slotted-content',
  message: "Element with a slot='...' attribute must be a child of a component "
      'or a descendant of a custom element',
);

const ErrorCode invalidAttributeHead = (
  code: 'invalid-attribute',
  message: '<svelte:head> should not have any attributes or directives',
);

const ErrorCode invalidAction = (
  code: 'invalid-action',
  message: 'Actions can only be applied to DOM elements, not components',
);

const ErrorCode invalidClass = (
  code: 'invalid-class',
  message: 'Classes can only be applied to DOM elements, not components',
);

const ErrorCode invalidTransition = (
  code: 'invalid-transition',
  message: 'Transitions can only be applied to DOM elements, not components',
);

const ErrorCode invalidLet = (
  code: 'invalid-let',
  message: 'let directive value must be an identifier or an object/array '
      'pattern',
);

const ErrorCode invalidSlotDirective = (
  code: 'invalid-slot-directive',
  message: '<slot> cannot have directives',
);

const ErrorCode dynamicSlotName = (
  code: 'dynamic-slot-name',
  message: '<slot> name cannot be dynamic',
);

const ErrorCode invalidSlotName = (
  code: 'invalid-slot-name',
  message: 'default is a reserved word — it cannot be used as a slot name',
);

const ErrorCode invalidSlotAttributeValueMissing = (
  code: 'invalid-slot-attribute',
  message: 'slot attribute value is missing',
);

const ErrorCode invalidSlottedContentFragment = (
  code: 'invalid-slotted-content',
  message: '<svelte:fragment> must be a child of a component',
);

const ErrorCode illegalAttributeTitle = (
  code: 'illegal-attribute',
  message: '<title> cannot have attributes',
);

const ErrorCode illegalStructureTitle = (
  code: 'illegal-structure',
  message: '<title> can only contain text and {tags}',
);

ErrorCode duplicateTransition(String directive, String parentDirective) {
  String describe(String directive) {
    return directive == 'transition' ? "a 'transition'" : "an '$directive'";
  }

  String message;

  if (directive == parentDirective) {
    message = "An element can only have one '$directive' directive";
  } else {
    message = 'An element cannot have both ${describe(parentDirective)} '
        'directive and ${describe(directive)} directive';
  }

  return (code: 'duplicate-transition', message: message);
}

const ErrorCode contextualStore = (
  code: 'contextual-store',
  message: 'Stores must be declared at the top level of the component (this '
      'may change in a future version of Svelte)',
);

const ErrorCode defaultExport = (
  code: 'default-export',
  message: 'A component cannot have a default export',
);

const ErrorCode illegalDeclaration = (
  code: 'illegal-declaration',
  message: 'The \$ prefix is reserved, and cannot be used for variable and '
      'import names',
);

const ErrorCode illegalSubscription = (
  code: 'illegal-subscription',
  message: 'Cannot reference store value inside <script context="module">',
);

ErrorCode illegalGlobal(String name) {
  return (
    code: 'illegal-global',
    message: '$name is an illegal variable name',
  );
}

const ErrorCode illegalVariableDeclaration = (
  code: 'illegal-variable-declaration',
  message: 'Cannot declare same variable name which is imported inside '
      '<script context="module">',
);

ErrorCode cyclicalReactiveDeclaration(List<String> cycle) {
  return (
    code: 'cyclical-reactive-declaration',
    message: "Cyclical dependency detected: ${cycle.join(' → ')}",
  );
}

const ErrorCode invalidTagProperty = (
  code: 'invalid-tag-property',
  message: "tag name must be two or more words joined by the '-' character",
);

const ErrorCode invalidTagAttribute = (
  code: 'invalid-tag-attribute',
  message: "'tag' must be a string literal",
);

ErrorCode invalidNamespaceProperty(String namespace, String? suggestion) {
  String message = "Invalid namespace '$namespace'";

  if (suggestion != null) {
    message += " (did you mean '$suggestion'?)";
  }

  return (code: 'invalid-namespace-property', message: message);
}

const ErrorCode invalidNamespaceAttribute = (
  code: 'invalid-namespace-attribute',
  message: "The 'namespace' attribute must be a string literal representing a "
      'valid namespace',
);

ErrorCode invalidAttributeValue(String name) {
  return (
    code: 'invalid-$name-value',
    message: '$name attribute must be true or false',
  );
}

const ErrorCode invalidOptionsAttributeUnknown = (
  code: 'invalid-options-attribute',
  message: '<svelte:options> unknown attribute',
);

const ErrorCode invalidOptionsAttribute = (
  code: 'invalid-options-attribute',
  message: "<svelte:options> can only have static 'tag', 'namespace', "
      "'accessors', 'immutable' and 'preserveWhitespace' attributes",
);

const ErrorCode cssInvalidGlobal = (
  code: 'css-invalid-global',
  message: ':global(...) can be at the start or end of a selector sequence, '
      'but not in the middle',
);

const ErrorCode cssInvalidGlobalSelector = (
  code: 'css-invalid-global-selector',
  message: ':global(...) must contain a single selector',
);

const ErrorCode cssInvalidGlobalSelectorPosition = (
  code: 'css-invalid-global-selector-position',
  message: ':global(...) not at the start of a selector sequence should not '
      'contain type or universal selectors',
);

ErrorCode cssInvalidSelector(String selector) {
  return (
    code: 'css-invalid-selector',
    message: 'Invalid selector "$selector"',
  );
}

const ErrorCode duplicateAnimation = (
  code: 'duplicate-animation',
  message: "An element can only have one 'animate' directive",
);

const ErrorCode invalidAnimationImmediate = (
  code: 'invalid-animation',
  message: 'An element that uses the animate directive must be the immediate '
      'child of a keyed each block',
);

const ErrorCode invalidAnimationKey = (
  code: 'invalid-animation',
  message: 'An element that uses the animate directive must be used inside a '
      'keyed each block. Did you forget to add a key to your each block?',
);

const ErrorCode invalidAnimationSole = (
  code: 'invalid-animation',
  message: 'An element that uses the animate directive must be the sole child '
      'of a keyed each block',
);

const ErrorCode invalidAnimationDynamicElement = (
  code: 'invalid-animation',
  message: '<svelte:element> cannot have a animate directive',
);

const ErrorCode invalidDirectiveValue = (
  code: 'invalid-directive-value',
  message: 'Can only bind to an identifier (e.g. "foo") or a member expression '
      '(e.g. "foo.bar" or "foo[baz]")',
);

const ErrorCode invalidConstPlacement = (
  code: 'invalid-const-placement',
  message: '{@const} must be the immediate child of {#if}, {:else if}, '
      '{:else}, {#each}, {:then}, {:catch}, <svelte:fragment> or <Component>',
);

ErrorCode invalidConstDeclaration(String name) {
  return (
    code: 'invalid-const-declaration',
    message: "'$name' has already been declared",
  );
}

ErrorCode invalidConstUpdate(String name) {
  return (
    code: 'invalid-const-update',
    message: "'$name' is declared using {@const ...} and is read-only",
  );
}

ErrorCode cyclicalConstTags(List<String> cycle) {
  return (
    code: 'cyclical-const-tags',
    message: "Cyclical dependency detected: ${cycle.join(' → ')}",
  );
}

const ErrorCode invalidComponentStyleDirective = (
  code: 'invalid-component-style-directive',
  message: 'Style directives cannot be used on components',
);

ErrorCode invalidStyleDirectiveModifier(String valid) {
  return (
    code: 'invalid-style-directive-modifier',
    message: 'Valid modifiers for style directives are: $valid',
  );
}
