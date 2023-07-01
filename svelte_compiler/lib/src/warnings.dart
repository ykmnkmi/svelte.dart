typedef WarningCode = ({String code, String message});

const WarningCode tagOptionDeprecated = (
  code: 'tag-option-deprecated',
  message: "'tag' option is deprecated — use 'customElement' instead",
);

WarningCode unusedExportLet(String component, String property) {
  return (
    code: 'unused-export-let',
    message: "$component has unused export property '$property'. If it is for "
        'external reference only, please consider using external $property',
  );
}

const WarningCode moduleScriptReactiveDeclaration = (
  code: 'module-script-reactive-declaration',
  message: '\$: has no effect in a module script',
);

const WarningCode nonTopLevelReactiveDeclaration = (
  code: 'non-top-level-reactive-declaration',
  message: '\$: has no effect outside of the top-level',
);

WarningCode moduleScriptVariableReactiveDeclaration(List<String> names) {
  return (
    code: 'module-script-reactive-declaration',
    message: '${names.map<String>((String name) => '"$name"').join(', ')} '
        '${names.length > 1 ? 'are' : 'is'} declared in a module script and will not be reactive',
  );
}

WarningCode missingDeclaration(String name, bool hasScript) {
  String message = "'$name' is not defined";

  if (hasScript) {
    message += ". Consider adding a <script> block with 'export let $name' to "
        'declare a prop';
  }

  return (
    code: 'missing-declaration',
    message: message,
  );
}

const WarningCode missingCustomElementCompileOptions = (
  code: 'missing-custom-element-compile-options',
  message:
      "The 'customElement' option is used when generating a custom element. Did you forget the 'customElement: true' compile option?",
);

WarningCode cssUnusedSelector(String selector) {
  return (
    code: 'css-unused-selector',
    message: 'Unused CSS selector "$selector"',
  );
}

const WarningCode emptyBlock = (
  code: 'empty-block',
  message: 'Empty block',
);

WarningCode reactiveComponent(String name) {
  return (
    code: 'reactive-component',
    message: '<$name/> will not be reactive if $name changes. Use '
        '<svelte:component this={$name}/> if you want this reactivity.',
  );
}

WarningCode componentNameLowercase(String name) {
  return (
    code: 'component-name-lowercase',
    message: '<$name> will be treated as an HTML element unless it begins with '
        'a capital letter',
  );
}

const WarningCode avoidIs = (
  code: 'avoid-is',
  message: "The 'is' attribute is not supported cross-browser and should be "
      'avoided',
);

WarningCode invalidHtmlAttribute(String name) {
  return (
    code: 'invalid-html-attribute',
    message: "'$name' is not a valid HTML attribute.",
  );
}

WarningCode a11yAriaAttributes(String name) {
  return (
    code: 'a11y-aria-attributes',
    message: 'A11y: <$name> should not have aria-* attributes',
  );
}

WarningCode a11yIncorrectAttributeType(dynamic schema, String attribute) {
  String message = switch (schema.type) {
    'boolean' => "The value of '$attribute' must be exactly one of true or "
        'false',
    'id' => "The value of '$attribute' must be a string that represents a DOM"
        ' element ID',
    'idlist' => "The value of '$attribute' must be a space-separated list of "
        'strings that represent DOM element IDs',
    'tristate' => "The value of '$attribute' must be exactly one of true, "
        'false, or mixed',
    'token' => "The value of '$attribute' must be exactly one of "
        "${(schema.values ?? <String>[]).join(', ')}",
    'tokenlist' => "The value of '$attribute' must be a space-separated list "
        "of one or more of ${(schema.values ?? <String>[]).join(', ')}",
    _ => "The value of '$attribute' must be of type ${schema.type}",
  };

  return (
    code: 'a11y-incorrect-aria-attribute-type',
    message: 'A11y: $message',
  );
}

WarningCode a11yUnknownAriaAttribute(String attribute) => (
      code: 'a11y-unknown-aria-attribute',
      message: "A11y: Unknown aria attribute 'aria-$attribute'",
    );

WarningCode a11yHidden(String name) {
  return (
    code: 'a11y-hidden',
    message: 'A11y: <$name> element should not be hidden',
  );
}

WarningCode a11yMisplacedRole(String name) {
  return (
    code: 'a11y-misplaced-role',
    message: 'A11y: <$name> should not have role attribute',
  );
}

WarningCode a11yUnknownRole(String role) {
  return (
    code: 'a11y-unknown-role',
    message: "A11y: Unknown role '$role'",
  );
}

WarningCode a11yNoAbstractRole(String role) {
  return (
    code: 'a11y-no-abstract-role',
    message: "A11y: Abstract role '$role' is forbidden",
  );
}

WarningCode a11yNoRedundantRoles(String role) {
  return (
    code: 'a11y-no-redundant-roles',
    message: "A11y: Redundant role '$role'",
  );
}

WarningCode a11yNoStaticElementInteractions(
  String element,
  List<String> handlers,
) {
  return (
    code: 'a11y-no-static-element-interactions',
    message: "A11y: <$element> with ${handlers.join(', ')} "
        "${handlers.length == 1 ? 'handler' : 'handlers'} must have an ARIA role",
  );
}

WarningCode a11yNoInteractiveElementToNoninteractiveRole(
  String role,
  String element,
) {
  return (
    code: 'a11y-no-interactive-element-to-noninteractive-role',
    message: "A11y: <$element> cannot have role '$role'",
  );
}

WarningCode a11yNoNoninteractiveElementInteractions(String element) {
  return (
    code: 'a11y-no-noninteractive-element-interactions',
    message: 'A11y: Non-interactive element <$element> should not be assigned '
        'mouse or keyboard event listeners.',
  );
}

WarningCode a11yNoNoninteractiveElementToInteractiveRole(
  String role,
  String element,
) {
  return (
    code: 'a11y-no-noninteractive-element-to-interactive-role',
    message: 'A11y: Non-interactive element <$element> cannot have interactive '
        "role '$role'",
  );
}

WarningCode a11yRoleHasRequiredAriaProps(String role, List<String> props) {
  return (
    code: 'a11y-role-has-required-aria-props',
    message: 'A11y: Elements with the ARIA role "$role" must have the '
        'following attributes defined: ${props.map<String>((name) => '"$name"').join(', ')}',
  );
}

WarningCode a11yRoleSupportsAriaProps(
  String attribute,
  String role,
  bool isImplicit,
  String name,
) {
  String message = "The attribute '$attribute' is not supported by the role "
      "'$role'.";

  if (isImplicit) {
    message += ' This role is implicit on the element <$name>.';
  }

  return (
    code: 'a11y-role-supports-aria-props',
    message: 'A11y: $message',
  );
}

const WarningCode a11yAccesskey = (
  code: 'a11y-accesskey',
  message: 'A11y: Avoid using accesskey',
);

const WarningCode a11yAutofocus = (
  code: 'a11y-autofocus',
  message: 'A11y: Avoid using autofocus',
);

const WarningCode a11yMisplacedScope = (
  code: 'a11y-misplaced-scope',
  message: 'A11y: The scope attribute should only be used with <th> elements',
);

const WarningCode a11yPositiveTabindex = (
  code: 'a11y-positive-tabindex',
  message: 'A11y: avoid tabindex values above zero',
);

WarningCode a11yInvalidAttribute(String hrefAttribute, String hrefValue) {
  return (
    code: 'a11y-invalid-attribute',
    message: "A11y: '$hrefValue' is not a valid $hrefAttribute attribute",
  );
}

WarningCode a11yMissingAttribute(
  String name,
  String article,
  String sequence,
) {
  return (
    code: 'a11y-missing-attribute',
    message: 'A11y: <$name> element should have $article $sequence attribute',
  );
}

WarningCode a11yAutocompleteValid(String? type, String value) {
  return (
    code: 'a11y-autocomplete-valid',
    message: "A11y: The value '$value' is not supported by the attribute "
        "'autocomplete' on element <input type=\"${type ?? '...'}\">",
  );
}

const WarningCode a11yImgRedundantAlt = (
  code: 'a11y-img-redundant-alt',
  message: 'A11y: Screenreaders already announce <img> elements as an image.',
);

WarningCode a11yInteractiveSupportsFocus(String role) {
  return (
    code: 'a11y-interactive-supports-focus',
    message: "A11y: Elements with the '$role' interactive role must have a "
        'tabindex value.',
  );
}

const WarningCode a11yLabelHasAssociatedControl = (
  code: 'a11y-label-has-associated-control',
  message: 'A11y: A form label must be associated with a control.',
);

const WarningCode a11yMediaHasCaption = (
  code: 'a11y-media-has-caption',
  message: 'A11y: <video> elements must have a <track kind="captions">',
);

WarningCode a11yDistractingElements(String name) {
  return (
    code: 'a11y-distracting-elements',
    message: 'A11y: Avoid <$name> elements',
  );
}

const WarningCode a11yStructureImmediate = (
  code: 'a11y-structure',
  message: 'A11y: <figcaption> must be an immediate child of <figure>',
);

const WarningCode a11yStructureFirstOrLast = (
  code: 'a11y-structure',
  message: 'A11y: <figcaption> must be first or last child of <figure>',
);

WarningCode a11yMouseEventsHaveKeyEvents(
  String event,
  String accompaniedBy,
) {
  return (
    code: 'a11y-mouse-events-have-key-events',
    message: 'A11y: on:$event must be accompanied by on:$accompaniedBy',
  );
}

const WarningCode a11yClickEventsHaveKeyEvents = (
  code: 'a11y-click-events-have-key-events',
  message:
      'A11y: visible, non-interactive elements with an on:click event must be accompanied by an on:keydown, on:keyup, or on:keypress event.',
);

WarningCode a11yMissingContent(String name) => (
      code: 'a11y-missing-content',
      message: 'A11y: <$name> element should have child content',
    );

const WarningCode a11yNoNoninteractiveTabindex = (
  code: 'a11y-no-noninteractive-tabindex',
  message:
      'A11y: noninteractive element cannot have nonnegative tabIndex value',
);

const WarningCode a11yAriaActivedescendantHasTabindex = (
  code: 'a11y-aria-activedescendant-has-tabindex',
  message:
      'A11y: Elements with attribute aria-activedescendant should have tabindex value',
);

const WarningCode redundantEventModifierForTouch = (
  code: 'redundant-event-modifier',
  message:
      "Touch event handlers that don't use the 'event' object are passive by default",
);

const WarningCode redundantEventModifierPassive = (
  code: 'redundant-event-modifier',
  message: 'The passive modifier only works with wheel and touch events',
);

WarningCode invalidRestEachblockBinding(String restElementName) {
  return (
    code: 'invalid-rest-eachblock-binding',
    message: 'The rest operator (...) will create a new object and binding '
        "'$restElementName' with the original object will not work",
  );
}

const WarningCode avoidMouseEventsOnDocument = (
  code: 'avoid-mouse-events-on-document',
  message: 'Mouse enter/leave events on the document are not supported in all '
      'browsers and should be avoided',
);

const WarningCode illegalAttributeCharacter = (
  code: 'illegal-attribute-character',
  message: "Attributes should not contain ':' characters to prevent ambiguity "
      'with Svelte directives',
);
