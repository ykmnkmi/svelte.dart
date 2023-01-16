import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parser/errors.dart';
import 'package:nutty/src/compiler/parser/html.dart';
import 'package:nutty/src/compiler/parser/names.dart';
import 'package:nutty/src/compiler/parser/parser.dart';
import 'package:source_span/source_span.dart';

const Map<String, String> metaTags = <String, String>{
  'svelte:head': 'Head',
  'svelte:options': 'Options',
  'svelte:window': 'Window',
  'svelte:body': 'Body',
};

const List<String> validMetaTags = <String>[
  'svelte:head',
  'svelte:options',
  'svelte:window',
  'svelte:body',
  'svelte:self',
  'svelte:component',
  'svelte:fragment',
  'svelte:element'
];

final RegExp tagNameRe = RegExp('^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*');

final RegExp tagNameEndRe = RegExp('(\\s|\\/|>)');

final RegExp attributeNameEndRe = RegExp('[\\s=\\/>"\']');

final RegExp attributeValueEndRe = RegExp('(\\/>|[\\s"\'=<>`])');

final RegExp quoteRe = RegExp('["\']');

final RegExp componentRe = RegExp('^[A-Z]');

final RegExp svelteSelfRe = RegExp('^svelte:self(?=[\\s/>])');

final RegExp svelteComponentRe = RegExp('^svelte:component(?=[\\s/>])');

final RegExp svelteElementRe = RegExp('^svelte:element(?=[\\s/>])');

final RegExp svelteFragmentRe = RegExp('^svelte:fragment(?=[\\s/>])');

String? getDirectiveType(String name) {
  switch (name) {
    case 'use':
      return 'Action';
    case 'animate':
      return 'Animation';
    case 'bind':
      return 'Binding';
    case 'class':
      return 'Class';
    case 'style':
      return 'StyleDirective';
    case 'on':
      return 'EventHandler';
    case 'let':
      return 'Let';
    case 'ref':
      return 'Ref';
    case 'in':
    case 'out':
    case 'transition':
      return 'Transition';
    default:
      return null;
  }
}

bool parentIsHead(List<Node> stack) {
  for (var node in stack.reversed) {
    var type = node.type;

    if (type == 'Head') {
      return true;
    }

    if (type == 'ELement' || type == 'InlineComponent') {
      return false;
    }
  }

  return false;
}

extension TagScanner on Parser {
  bool readAttributeTo(List<Node> attributes, Set<String> uniqueNames) {
    var start = position;

    void checkUnique(String name) {
      if (uniqueNames.contains(name)) {
        duplicateAttribute(start);
      }

      uniqueNames.add(name);
    }

    if (scan('{')) {
      // TODO(parser): parse attribute expression
      throw UnimplementedError();
    }

    var name = readUntil(attributeNameEndRe);

    if (name.isEmpty) {
      return false;
    }

    var end = position;

    allowSpace();

    var colonIndex = name.indexOf(':');

    String? type;

    if (colonIndex != -1) {
      type = getDirectiveType(name.substring(0, colonIndex));
    }

    var values = <Node>[];

    if (scan('=')) {
      allowSpace();

      values = readAttributeValue();
      end = position;
    } else if (match(quoteRe)) {
      unexpectedToken('=', position);
    }

    if (type != null) {
      var parts = name.substring(colonIndex + 1).split('|');
      var directiveName = parts.first;
      var modifiers = parts.sublist(1);

      if (directiveName == '') {
        emptyDirectiveName(type, start + colonIndex + 1);
      }

      if (type == 'Binding' && directiveName != 'this') {
        checkUnique(directiveName);
      } else if (type != 'EventHandler' && type != 'Action') {
        checkUnique(name);
      }

      if (type == 'Ref') {
        invalidRefDirective(directiveName, start);
      }

      if (type == 'StyleDirective') {
        attributes.add(Node(
          start: start,
          end: end,
          type: type,
          name: directiveName,
          modifiers: modifiers,
          values: values,
        ));
      }

      Node? firstValue;

      Object? expression;

      if (values.isNotEmpty) {
        firstValue = values.first;

        if (values.length > 1 || firstValue.type == 'Text') {
          invalidDirectiveValue(firstValue.start);
        } else {
          expression = firstValue.expression;
        }
      }

      var directive = Node(
        start: start,
        end: end,
        type: type,
        name: directiveName,
        modifiers: modifiers,
        expression: expression,
      );

      if (type == 'Transition') {
        var direction = name.substring(0, colonIndex);

        directive
          ..intro = direction == 'in' || direction == 'transition'
          ..outro = direction == 'out' || direction == 'transition';
      }

      if (expression == null && (type == 'Binding' || type == 'Class')) {
        // TODO(parser): parse expression
        throw UnimplementedError();
      }

      attributes.add(directive);
      return true;
    }

    checkUnique(name);

    attributes.add(Node(
      start: start,
      end: end,
      type: 'Attribute',
      name: name,
      values: values,
    ));

    return true;
  }

  List<Node> readAttributeValue() {
    var quoteMark = read('"') ?? read("'");

    if (quoteMark != null && scan(quoteMark)) {
      return <Node>[
        Node(
          start: position - 1,
          end: position - 1,
          type: 'Text',
          text: '',
          raw: '',
        )
      ];
    }

    var endRe = quoteMark ?? attributeValueEndRe;
    List<Node> values;

    try {
      values = readSequence(endRe, 'in attribute value');
    } on ParseError catch (error) {
      if (error.code == 'parse-error') {
        var offset = error.span.start.offset;
        var substring = template.substring(offset - 1, offset + 1);

        if (substring == '/>') {
          position = offset;
          unclosedAttributeValue(quoteMark ?? '}');
        }
      }

      rethrow;
    }

    if (values.isEmpty && quoteMark == null) {
      missingAttributeValue();
    }

    if (quoteMark != null) {
      expect(quoteMark);
    }

    return values;
  }

  List<Node> readSequence(Pattern endRe, String location) {
    var textStart = position;
    var chunks = <Node>[];

    void flush(int end) {
      if (textStart < end) {
        var raw = template.substring(textStart, end);
        var text = decodeCharacterReferences(raw);

        chunks.add(Node(
          start: textStart,
          end: end,
          type: 'Text',
          text: text,
          raw: raw,
        ));
      }
    }

    while (isNotDone) {
      if (match(endRe)) {
        flush(position);
        return chunks;
      }

      if (scan('{')) {
        if (scan('#')) {
          var index = position - 2;
          var name = readUntil(RegExp('[^a-z]'));
          invalidLogicBlockPlacement(location, name, index);
        }

        if (scan('@')) {
          var index = position - 2;
          var name = readUntil(RegExp('[^a-z]'));
          invalidTagPlacement(location, name, index);
        }

        // TODO(parser): parse mustache
        throw UnimplementedError();
      } else {
        position += 1;
      }
    }

    return chunks;
  }

  String readTagName() {
    var start = position;

    if (scan(svelteSelfRe)) {
      for (var node in stack.reversed) {
        if (node.type == 'IfBlock' ||
            node.type == 'EachBlock' ||
            node.type == 'InlineComponent') {
          return 'svelte:self';
        }
      }

      invalidSelfPlacement(start);
    }

    if (scan(svelteComponentRe)) {
      return 'svelte:component';
    }

    if (scan(svelteElementRe)) {
      return 'svelte:element';
    }

    if (scan(svelteFragmentRe)) {
      return 'svelte:fragment';
    }

    var name = readUntil(tagNameEndRe);

    if (metaTags.containsKey(name)) {
      return name;
    }

    if (name.startsWith('svelte:')) {
      invalidTagNameSvelteElement(validMetaTags, start);
    }

    if (tagNameRe.hasMatch(name)) {
      return name;
    }

    invalidTagName(start);
  }

  void tag() {
    var start = position;

    expect('<');

    if (scan('!--')) {
      var text = readUntil('-->');

      expect('-->', unclosedComment);

      current.children.add(Node(
        start: start,
        end: position,
        type: 'Comment',
        text: text,
      ));

      return;
    }

    var parent = current;

    var isClosingTag = scan('/');
    var name = readTagName();
    var type = metaTags[name];

    if (type != null) {
      var slug = type.toLowerCase();

      if (isClosingTag) {
        if ((name == 'svelte:window' || name == 'svelte:body') &&
            parent.children.isNotEmpty) {
          invalidElementContent(slug, name, parent.children.first.start);
        }
      } else {
        if (this.metaTags.contains(name)) {
          duplicateElement(slug, name, start);
        }

        if (stack.isNotEmpty) {
          invalidElementPlacement(slug, name, start);
        }

        this.metaTags.add(name);
      }
    } else if (componentRe.hasMatch(name) ||
        name == 'svelte:self' ||
        name == 'svelte:component') {
      type = 'InlineComponent';
    } else if (name == 'svelte:fragment') {
      type = 'SlotTemplate';
    } else if (name == 'title' && parentIsHead(stack)) {
      type = 'Title';
    } else if (name == 'slot') {
      type = 'Slot';
    } else {
      type = 'Element';
    }

    var element = Node(start: start, type: type, name: name);

    allowSpace();

    if (isClosingTag) {
      if (isVoid(name)) {
        invalidVoidContent(name, start);
      }

      expect('>');

      var lastAutoCloseTag = this.lastAutoCloseTag;

      while (parent.name != name) {
        if (parent.type != 'Element') {
          if (lastAutoCloseTag != null && lastAutoCloseTag.tag == name) {
            invalidClosingTagAutoClosed(name, lastAutoCloseTag.reason, start);
          } else {
            invalidClosingTagUnopened(name, start);
          }
        }

        parent.end = start;
        stack.removeLast();
        parent = current;
      }

      parent.end = start;
      stack.removeLast();

      if (lastAutoCloseTag != null && stack.length < lastAutoCloseTag.depth) {
        this.lastAutoCloseTag = null;
      }

      return;
    }

    if (closingTagOmitted(parent.name, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoCloseTag = AutoCloseTag(parent.name, name, stack.length);
    }

    var attributes = <Node>[];
    var uniqueNames = <String>{};

    while (readAttributeTo(attributes, uniqueNames)) {
      allowSpace();
    }

    if (attributes.isNotEmpty) {
      element.attributes = attributes;
    }

    // TODO(parser): parse svelte:component
    // TODO(parser): parse svelte:element
    // TODO(parser): parse specials

    current.children.add(element);

    var selfClosing = scan('/') || isVoid(name);

    expect('>');

    if (selfClosing) {
      element.end = position;
    } else if (name == 'textarea') {
      // TODO(parser): parse textarea
      throw UnimplementedError();
    } else {
      stack.add(element);
    }
  }
}
