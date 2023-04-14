const customElementNoTag = (
  code: 'custom-element-no-tag',
  message: "No custom element 'tag' option was specified. "
      'To automatically register a custom element, specify a name with a hyphen in it, e.g. <svelte:options tag="my-thing"/>. '
      'To hide this warning, use <svelte:options tag={null}/>',
);

({String code, String message}) unusedExportProperty(
  String? component,
  String? property,
) {
  return (
    code: 'unused-export-property',
    message: "$component has unused export property '$property'. "
        "If it is for external reference only, please consider using 'export const $property'"
  );
}

const moduleScriptReactiveDeclaration = (
  code: 'module-script-reactive-declaration',
  message: '\$: has no effect in a module script',
);

const nonTopLevelReactiveDeclaration = (
  code: 'non-top-level-reactive-declaration',
  message: '\$: has no effect outside of the top-level',
);

({String code, String message}) moduleScriptVariableReactiveDeclaration(
  List<String> names,
) {
  return (
    code: 'module-script-reactive-declaration',
    message: '${names.map((name) => "'$name'").join(', ')} '
        '${names.length > 1 ? 'are' : 'is'} declared in a module script and will not be reactive',
  );
}

({String code, String message}) missingDeclaration(
    String name, bool hasScript) {
  return (
    code: 'missing-declaration',
    message:
        "'$name' is not defined${hasScript ? '' : ". Consider adding a <script> block with 'export let $name' to declare a prop"}",
  );
}

const missingCustomElementCompileOptions = (
  code: 'missing-custom-element-compile-options',
  message:
      "The 'tag' option is used when generating a custom element. Did you forget the 'customElement: true' compile option?"
);

({String code, String message}) cssUnusedSelector(String selector) =>
    (code: 'css-unused-selector', message: "Unused CSS selector '$selector'");

const emptyBlock = (
  code: 'empty-block',
  message: 'Empty block',
);

({String code, String message}) reactiveComponent(String name) => (
      code: 'reactive-component',
      message:
          '<$name/> will not be reactive if $name changes. Use <svelte:component this={$name}/> if you want this reactivity.',
    );

({String code, String message}) componentNameLowercase(String name) => (
      code: 'component-name-lowercase',
      message:
          '<$name> will be treated as an HTML element unless it begins with a capital letter',
    );

const avoidIs = (
  code: 'avoid-is',
  message:
      "The 'is' attribute is not supported cross-browser and should be avoided"
);

({String code, String message}) invalidHtmlAttribute(
        String name, String suggestion) =>
    (
      code: 'invalid-html-attribute',
      message:
          "'$name' is not a valid HTML attribute. Did you mean '$suggestion'?"
    );

({String code, String message}) a11yAriaAttributes(String name) => (
      code: 'a11y-aria-attributes',
      message: 'A11y: <$name> should not have aria-* attributes',
    );

({String code, String message}) a11yIncorrectAttributeType(
    dynamic schema, String attribute) {
  String message;

  switch (schema.type) {
    case 'boolean':
      message =
          "The value of '$attribute' must be exactly one of true or false";
      break;
    case 'id':
      message =
          "The value of '$attribute' must be a string that represents a DOM element ID";
      break;
    case 'idlist':
      message =
          "The value of '$attribute' must be a space-separated list of strings that represent DOM element IDs";
      break;
    case 'tristate':
      message =
          "The value of '$attribute' must be exactly one of true, false, or mixed";
      break;
    case 'token':
      message =
          "The value of '$attribute' must be exactly one of ${(schema.values as List<Object?>? ?? <Object?>[]).join(', ')}";
      break;
    case 'tokenlist':
      message =
          "The value of '$attribute' must be a space-separated list of one or more of ${(schema.values as List<Object?>? ?? <Object?>[]).join(', ')}";
      break;
    default:
      message = "The value of '$attribute' must be of type ${schema.type}";
  }

  return (
    code: 'a11y-incorrect-aria-attribute-type',
    message: 'A11y: $message',
  );
}

({String code, String message}) a11yUnknownAriaAttribute(
        String attribute, String? suggestion) =>
    (
      code: 'a11y-unknown-aria-attribute',
      message:
          "A11y: Unknown aria attribute 'aria-$attribute'${suggestion == null ? '' : " (did you mean '$suggestion'?)"}",
    );

({String code, String message}) a11yHidden(String name) => (
      code: 'a11y-hidden',
      message: 'A11y: <$name> element should not be hidden',
    );

({String code, String message}) a11yMisplacedRole(String name) => (
      code: 'a11y-misplaced-role',
      message: 'A11y: <$name> should not have role attribute',
    );

({String code, String message}) a11yUnknownRole(
        String role, String? suggestion) =>
    (
      code: 'a11y-unknown-role',
      message:
          "A11y: Unknown role '$role'${suggestion == null ? '' : " (did you mean '$suggestion'?)"}",
    );

({String code, String message}) a11yNoAbstractRole(String role) => (
      code: 'a11y-no-abstract-role',
      message: "A11y: Abstract role '$role' is forbidden"
    );

({String code, String message}) a11yNoRedundantRoles(String role) =>
    (code: 'a11y-no-redundant-roles', message: "A11y: Redundant role '$role'");

({String code, String message}) a11yNoInteractiveElementToNoninteractiveRole(
        String role, String element) =>
    (
      code: 'a11y-no-interactive-element-to-noninteractive-role',
      message: "A11y: <$element> cannot have role '$role'"
    );

({String code, String message}) a11yRoleHasRequiredAriaProps(
        String role, List<String> props) =>
    (
      code: 'a11y-role-has-required-aria-props',
      message:
          "A11y: Elements with the ARIA role '$role' must have the following attributes defined: ${props.map((name) => "'$name'").join(', ')}",
    );

const a11yAccesskey = (
  code: 'a11y-accesskey',
  message: 'A11y: Avoid using accesskey',
);

const a11yAutofocus = (
  code: 'a11y-autofocus',
  message: 'A11y: Avoid using autofocus',
);

const a11yMisplacedScope = (
  code: 'a11y-misplaced-scope',
  message: 'A11y: The scope attribute should only be used with <th> elements',
);

const a11yPositiveTabindex = (
  code: 'a11y-positive-tabindex',
  message: 'A11y: avoid tabindex values above zero',
);

({String code, String message}) a11yInvalidAttribute(
        String hrefAttribute, String hrefValue) =>
    (
      code: 'a11y-invalid-attribute',
      message: "A11y: '$hrefValue' is not a valid $hrefAttribute attribute"
    );

({String code, String message}) a11yMissingAttribute(
        String name, String article, String sequence) =>
    (
      code: 'a11y-missing-attribute',
      message: 'A11y: <$name> element should have $article $sequence attribute',
    );

const a11yImgRedundantAlt = (
  code: 'a11y-img-redundant-alt',
  message: 'A11y: Screenreaders already announce <img> elements as an image.',
);

const a11yLabelHasAssociatedControl = (
  code: 'a11y-label-has-associated-control',
  message: 'A11y: A form label must be associated with a control.',
);

const a11yMediaHasCaption = (
  code: 'a11y-media-has-caption',
  message: 'A11y: <video> elements must have a <track kind="captions">',
);

({String code, String message}) a11yDistractingElements(String name) => (
      code: 'a11y-distracting-elements',
      message: 'A11y: Avoid <$name> elements',
    );

const a11yStructureImmediate = (
  code: 'a11y-structure',
  message: 'A11y: <figcaption> must be an immediate child of <figure>',
);

const a11yStructureFirstOrLast = (
  code: 'a11y-structure',
  message: 'A11y: <figcaption> must be first or last child of <figure>',
);

({String code, String message}) a11yMouseEventsHaveKeyEvents(
        String event, String accompaniedBy) =>
    (
      code: 'a11y-mouse-events-have-key-events',
      message: 'A11y: on:$event must be accompanied by on:$accompaniedBy',
    );

({String code, String message}) a11yClickEventsHaveKeyEvents() => (
      code: 'a11y-click-events-have-key-events',
      message:
          'A11y: visible, non-interactive elements with an on:click event must be accompanied by an on:keydown, on:keyup, or on:keypress event.',
    );

({String code, String message}) a11yMissingContent(String name) => (
      code: 'a11y-missing-content',
      message: 'A11y: <$name> element should have child content',
    );

const a11yNoNoninteractiveTabindex = (
  code: 'a11y-no-noninteractive-tabindex',
  message:
      'A11y: noninteractive element cannot have nonnegative tabIndex value',
);

const redundantEventModifierForTouch = (
  code: 'redundant-event-modifier',
  message:
      "Touch event handlers that don't use the 'event' object are passive by default"
);

const redundantEventModifierPassive = (
  code: 'redundant-event-modifier',
  message: 'The passive modifier only works with wheel and touch events',
);

({String code, String message}) invalidRestEachblockBinding(
        String restElementName) =>
    (
      code: 'invalid-rest-eachblock-binding',
      message:
          '...$restElementName operator will create a new object and binding propagation with original object will not work',
    );
