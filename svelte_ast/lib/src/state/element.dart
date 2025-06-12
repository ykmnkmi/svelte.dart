import 'package:analyzer/dart/ast/ast.dart' as dart;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/html.dart';
import 'package:svelte_ast/src/names.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/read/expression.dart';
import 'package:svelte_ast/src/read/script.dart';
import 'package:svelte_ast/src/read/style.dart';

final RegExp _invalidUnquotedAttributeValueRe = RegExp('(\\/>|[\\s"\'=<>])');

final RegExp _closingTextareaTagRe = RegExp('</textarea\\s*>');

final RegExp _spaceOrSlashOrClosingTagEndRe = RegExp('(\\s|\\/|>)');

final RegExp _tokenEndingCharacterRe = RegExp('[\\s=/>"\']');

final RegExp _startsWithQuoteCharacters = RegExp('["\']');

final RegExp _attributeValueRe = RegExp(
  '(?:"([^"]*)"|\'([^\'])*\'|([^>\\s]+))',
);

final RegExp _notNameRe = RegExp('[^a-z]');

final RegExp _validElementNameRe = RegExp(
  '^(?:![a-zA-Z]+|[a-zA-Z](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|[a-zA-Z][a-zA-Z0-9]*:[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9])\$',
);

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar#identifiers
// adjusted for our needs (must start with uppercase letter if no dots, can
// contain dots).
final RegExp _validComponentNameRe = RegExp(
  '^(?:\\p{Lu}[\$\u200c\u200d\\p{ID_Continue}.]*|\\p{ID_Start}[\$\u200c\u200d\\p{ID_Continue}]*(?:\\.[\$\u200c\u200d\\p{ID_Continue}]+)+)\$',
  unicode: true,
);

const List<String> _rootOnlyMetaTags = <String>[
  'svelte:head',
  'svelte:options',
  'svelte:window',
  'svelte:document',
  'svelte:body',
];

const List<String> _metaTags = <String>[
  'svelte:head',
  'svelte:options',
  'svelte:window',
  'svelte:document',
  'svelte:body',
  'svelte:element',
  'svelte:component',
  'svelte:self',
  'svelte:fragment',
  'svelte:boundary',
];

bool _parentIsHead(List<Node> stack) {
  for (Node node in stack.reversed) {
    if (node is SvelteHead || node is RegularElement || node is Component) {
      return true;
    }
  }

  return false;
}

bool _parentIsShadowRootTemplate(List<Node> stack) {
  for (Node node in stack.reversed) {
    if (node is RegularElement) {
      for (AttributeNode attribute in node.attributes) {
        // TODO(ast): ShadowRoot: support or remove?
        if (attribute is NamedAttributeNode &&
            attribute.name == 'shadowrootmode') {
          return true;
        }
      }
    }
  }

  return false;
}

extension ElementParser on Parser {
  Attribute? _readStaticAttribute() {
    int start = position;

    String name = readUntil(_tokenEndingCharacterRe);

    if (name.isEmpty) {
      return null;
    }

    Object? value;

    if (scan('=')) {
      allowSpace();

      String? raw = read(_attributeValueRe);

      if (raw == null) {
        expectedAttributeValue(position);
      }

      bool quoted = raw[0] == '"' || raw[0] == "'";

      if (quoted) {
        raw = raw.substring(1, raw.length - 1);
      }

      value = Text(
        start: start,
        end: quoted ? position - 1 : position,
        raw: raw,
        data: decodeCharacterReferences(raw, true),
      );
    }

    if (match(_startsWithQuoteCharacters)) {
      expectedToken('=', position);
    }

    return Attribute(start: start, end: position, name: name, value: value);
  }

  AttributeNode? _readAttribute() {
    int start = position;

    if (scan('{')) {
      allowSpace();

      if (scan('...')) {
        dart.Expression expression = readExpression('}');
        allowSpace();
        expect('}');

        return SpreadAttribute(
          start: start,
          end: position,
          expression: expression,
        );
      }

      int valueStart = position;
      String? name = readIdentifier();

      if (name == null) {
        attributeEmptyShorthand(start);
      }

      allowSpace();
      expect('}');

      return Attribute(
        start: start,
        end: position,
        name: name,
        value: ExpressionTag(
          start: valueStart,
          end: valueStart + name.length,
          expression: simpleIdentifier(valueStart, name),
        ),
      );
    }

    String name = readUntil(_tokenEndingCharacterRe);

    if (name.isEmpty) {
      return null;
    }

    int end = position;
    allowSpace();

    List<Node>? values;

    if (scan('=')) {
      allowSpace();

      if (scan('/') && match('>')) {
        values = <Node>[
          Text(start: position - 1, end: position, raw: '/', data: '/'),
        ];

        end = position;
      } else {
        values = _readAttributeValue();
        end = position;
      }
    } else if (match(_startsWithQuoteCharacters)) {
      expectedToken('=', position);
    }

    int colonIndex = name.indexOf(':');

    if (colonIndex != -1) {
      String type = name.substring(0, colonIndex);
      List<String> modifiers = name.substring(colonIndex + 1).split('|');
      String directiveName = modifiers.removeAt(0);

      if (type == 'style') {
        return StyleDirective(
          start: start,
          end: end,
          name: directiveName,
          modifiers: modifiers,
          value: values,
        );
      }

      dart.Expression? expression;

      if (values != null && values.isNotEmpty) {
        Node firstValue = values.first;

        if (firstValue is! ExpressionTag) {
          directiveInvalidValue(firstValue.start);
        }

        expression = firstValue.expression;
      }

      DirectiveNode directiveNode;

      if (type == 'use') {
        directiveNode = UseDirective(
          start: start,
          end: end,
          name: directiveName,
          expression: expression,
        );
      } else if (type == 'animate') {
        directiveNode = AnimationDirective(
          start: start,
          end: end,
          name: directiveName,
          expression: expression,
        );
      } else if (type == 'bind') {
        directiveNode = BindDirective(
          start: start,
          end: end,
          name: directiveName,
          // If directive name is expression, e.g. `<p class:isRed />`.
          expression: expression ?? simpleIdentifier(start, directiveName),
        );
      } else if (type == 'class') {
        directiveNode = ClassDirective(
          start: start,
          end: end,
          name: directiveName,
          // If directive name is expression, e.g. `<p class:isRed />`.
          expression: expression ?? simpleIdentifier(start, directiveName),
        );
      } else if (type == 'on') {
        directiveNode = OnDirective(
          start: start,
          end: end,
          name: directiveName,
          expression: expression,
          modifiers: modifiers,
        );
      } else if (type == 'let') {
        directiveNode = LetDirective(
          start: start,
          end: end,
          name: directiveName,
          expression: expression,
          modifiers: modifiers,
        );
      } else if (type == 'in' || type == 'out' || type == 'transition') {
        directiveNode = TransitionDirective(
          start: start,
          end: end,
          name: directiveName,
          expression: expression,
          modifiers: modifiers,
          intro: type == 'in' || type == 'transition',
          outro: type == 'out' || type == 'transition',
        );
      } else {
        directiveMissingName(name, start, start + colonIndex + 1);
      }

      return directiveNode;
    }

    return Attribute(start: start, end: end, name: name, value: values);
  }

  List<Node> _readAttributeValue() {
    String? quoteMark = read('"') ?? read("'");

    if (quoteMark != null && scan(quoteMark)) {
      return <Node>[
        Text(start: position - 1, end: position - 1, raw: '', data: ''),
      ];
    }

    List<Node> values;

    try {
      values = _readSequence(
        quoteMark ?? _invalidUnquotedAttributeValueRe,
        'in attribute value',
      );
    } on ParseError catch (error) {
      if (error.code == 'dart_parse_error') {
        // If the attribute value didn't close + self-closing tag
        // eg: `<Component test={{'a':1} />` analyzer may throw a
        // `Expected an identifier` because of `/>`.
        int position = error.span.start.offset;

        if (template.substring(position - 1, position + 1) == '/>') {
          position = position;
          expectedToken(quoteMark ?? '}', position);
        }
      }

      rethrow;
    }

    if (quoteMark == null) {
      if (values.isEmpty) {
        expectedAttributeValue(position);
      }
    } else {
      expect(quoteMark);
    }

    return values;
  }

  List<Node> _readSequence(Pattern end, String location) {
    int textStart = position;
    StringBuffer buffer = StringBuffer();

    List<Node> chunks = <Node>[];

    void flush(int end) {
      if (buffer.isNotEmpty) {
        String raw = buffer.toString();

        Text chunk = Text(
          start: textStart,
          end: end,
          raw: raw,
          data: decodeCharacterReferences(raw, true),
        );

        chunks.add(chunk);
      }
    }

    while (isNotDone) {
      int expressionStart = position;

      if (match(end)) {
        flush(expressionStart);
        return chunks;
      }

      if (scan('{')) {
        if (scan('#')) {
          String name = readUntil(_notNameRe);
          blockInvalidPlacement(name, location, expressionStart);
        } else if (scan('@')) {
          String name = readUntil(_notNameRe);
          tagInvalidPlacement(name, location, expressionStart);
        }

        flush(expressionStart);
        allowSpace();

        dart.Expression expression = readExpression('}');
        allowSpace();
        expect('}');

        ExpressionTag chunk = ExpressionTag(
          start: expressionStart,
          end: position,
          expression: expression,
        );

        chunks.add(chunk);

        textStart = position;
        buffer.clear();
      } else {
        buffer.write(template[position++]);
      }
    }

    unexpectedEOF(length);
  }

  void element(int start) {
    if (scan('!--')) {
      String data = readUntil('-->');
      expect('-->');

      add(Comment(start: start, end: position, data: data));
      return;
    }

    Node parent = current;
    bool isClosingTag = scan('/');
    String name = readUntil(_spaceOrSlashOrClosingTagEndRe);

    if (isClosingTag) {
      allowSpace();
      expect('>');

      if (isVoid(name)) {
        voidElementInvalidContent(start);
      }

      AutoClosedTag? tag = lastAutoClosedTag;

      // Closing any elements that don't have their own closing tags,
      // e.g. <div><p></div>.
      while (parent is! ElementNode || parent.name != name) {
        if (parent is! ElementNode) {
          if (tag != null && tag.tag == name) {
            elementInvalidClosingTagAutoClosed(start, name, tag.reason);
          } else {
            elementInvalidClosingTag(name, start);
          }
        }

        parent.end = start;
        pop();

        parent = current;
      }

      parent.end = position;
      pop();

      if (tag != null && stack.length < tag.depth) {
        lastAutoClosedTag = null;
      }

      return;
    }

    if (name.startsWith('svelte:') && !_metaTags.contains(name)) {
      svelteMetaInvalidTag(_metaTags, start + 1, start + 1 + name.length);
    }

    if (!_validElementNameRe.hasMatch(name) &&
        !_validComponentNameRe.hasMatch(name)) {
      // <div. -> in the middle of typeing -> allow in loose mode.
      if (!name.endsWith('.')) {
        tagInvalidName(start + 1, start + 1 + name.length);
      }
    }

    if (_rootOnlyMetaTags.contains(name)) {
      if (metaTags.contains(name)) {
        svelteMetaDuplicate(name, start);
      }

      if (parent is! Root) {
        svelteMetaInvalidPlacement(name, start);
      }

      metaTags.add(name);
    }

    ElementNode element;

    if (name == 'svelte:head') {
      element = SvelteHead(start: start);
    } else if (name == 'svelte:options') {
      element = SvelteOptions(start: start, attributes: <AttributeNode>[]);
    } else if (name == 'svelte:window') {
      element = SvelteWindow(start: start, attributes: <AttributeNode>[]);
    } else if (name == 'svelte:document') {
      element = SvelteDocument(start: start, attributes: <AttributeNode>[]);
    } else if (name == 'svelte:body') {
      element = SvelteBody(start: start, attributes: <AttributeNode>[]);
    } else if (name == 'svelte:element') {
      element = SvelteElement(
        start: start,
        tag: null,
        attributes: <AttributeNode>[],
      );
    } else if (name == 'svelte:component') {
      element = SvelteComponent(start: start, attributes: <AttributeNode>[]);
    } else if (name == 'svelte:self') {
      element = SvelteSelf(start: start, attributes: <AttributeNode>[]);
    } else if (name == 'svelte:fragment') {
      element = SvelteFragment(start: start, attributes: <AttributeNode>[]);
    } else if (name == 'svelte:boundary') {
      element = SvelteBoundary(start: start, attributes: <AttributeNode>[]);
    } else if (_validComponentNameRe.hasMatch(name)) {
      element = Component(
        start: start,
        name: name,
        attributes: <AttributeNode>[],
      );
    } else if (name == 'title' && _parentIsHead(stack)) {
      element = TitleElement(start: start);
    } else if (name == 'slot' && !_parentIsShadowRootTemplate(stack)) {
      element = SlotElement(start: start, attributes: <AttributeNode>[]);
    } else {
      element = RegularElement(
        start: start,
        name: name,
        attributes: <AttributeNode>[],
      );
    }

    allowSpace();

    if (parent is RegularElement && closingTagOmitted(parent.name, name)) {
      parent.end = start;
      pop();
      lastAutoClosedTag = (tag: parent.name, reason: name, depth: stack.length);
    }

    Set<String> uniqueNames = <String>{};

    Node currentNode = current;
    bool isTopLevelScriptOrStyle =
        (name == 'script' || name == 'style') && currentNode is Root;

    AttributeNode? Function() read = isTopLevelScriptOrStyle
        ? _readStaticAttribute
        : _readAttribute;

    AttributeNode? attribute = read();

    while (attribute != null) {
      // Animate and transition can only be specified once per element so no
      // need to check here, use can be used multiple times, same for the on
      // directive finally let already has error handling in case of duplicate
      // variable names.
      if (attribute is UniqueNamedAttributeNode) {
        // `bind:attribute` and `attribute` are just the same but
        // `class:attribute`, `style:attribyte` and `attribute` are
        // different and should be allowed together so we concatenate the
        // type while normalizing the type for BindDirective.
        String uniqueName = attribute.uniqueName;

        if (!uniqueNames.add(uniqueName)) {
          // `<svelte:element bind:this this=...>` is allowed.
          attributeDuplicate(attribute.start, attribute.end);
        }
      }

      element.attributes.add(attribute);
      allowSpace();

      attribute = read();
    }

    svelte_component:
    if (element is SvelteComponent) {
      List<AttributeNode> attributes = element.attributes;

      for (int i = 0; i < attributes.length; i++) {
        AttributeNode attribute = attributes[i];

        if (attribute is Attribute && attribute.name == 'this') {
          attributes.removeAt(i);

          Object? value = attribute.value;

          if (value is List<Node> && value.length == 1) {
            Node first = value.first;

            if (first is ExpressionTag) {
              element.expression = first.expression;
              break svelte_component;
            }
          }

          svelteComponentInvalidThis(start);
        }
      }

      svelteComponentMissingThis(start);
    }

    svelte_element:
    if (element is SvelteElement) {
      List<AttributeNode> attributes = element.attributes;

      for (int i = 0; i < attributes.length; i++) {
        AttributeNode attribute = attributes[i];

        if (attribute is Attribute && attribute.name == 'this') {
          attributes.removeAt(i);

          Object? value = attribute.value;

          if (value == null) {
            svelteElementMissingThis(attribute.start, attribute.end);
          }

          if (value is List<Node> && value.length == 1) {
            Node first = value.first;

            if (first is ExpressionTag) {
              element.tag = first.expression;
              break svelte_element;
            }

            if (first is Text) {
              element.tag = simpleString(first.start, first.data);
              break svelte_element;
            }

            svelteElementInvalidThis(start);
          }
        }
      }

      svelteElementMissingThis(start);
    }

    if (isTopLevelScriptOrStyle) {
      expect('>');

      if (name == 'script') {
        Script script = readScript(start, element.attributes);

        switch (script) {
          case ModuleScript():
            if (currentNode.module != null) {
              scriptDuplicate(start);
            }

            currentNode.module = script;
            break;

          case InstanceScript():
            if (currentNode.instance != null) {
              scriptDuplicate(start);
            }

            currentNode.instance = script;
            break;
        }
      } else {
        Style style = readStyle(start, element.attributes);

        if (currentNode.style != null) {
          styleDuplicate(start);
        }

        currentNode.style = style;
      }

      return;
    }

    add(element);

    bool selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      // Don't push self-closing elements onto the stack.
      element.end = position;
    } else if (name == 'textarea') {
      assert(element.fragment.children.isEmpty);

      List<Node> readSequence = _readSequence(
        _closingTextareaTagRe,
        'inside <textarea>',
      );

      element.fragment.children.addAll(readSequence);
      expect(_closingTextareaTagRe);
      element.end = position;
    } else if (name == 'script' || name == 'style') {
      RegExp closingTagRe = name == 'script'
          ? closingScriptTagRe
          : closingStyleTagRe;

      int start = position;
      String data = readUntil(closingTagRe);
      int end = position;

      Text node = Text(start: start, end: end, raw: data, data: data);

      element.fragment.children.add(node);
      expect(closingTagRe);
      element.end = position;
    } else {
      stack.add(element);
      fragments.add(element.fragment);
    }
  }
}
