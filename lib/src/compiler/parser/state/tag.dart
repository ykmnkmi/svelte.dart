import 'package:analyzer/dart/ast/ast.dart' show Expression;
import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/extract_svelte_ignore.dart';
import 'package:svelte/src/compiler/parser/html.dart';
import 'package:svelte/src/compiler/parser/names.dart';
import 'package:svelte/src/compiler/parser/parser.dart';
import 'package:svelte/src/compiler/parser/read/expression.dart';
import 'package:svelte/src/compiler/parser/read/script.dart';
import 'package:svelte/src/compiler/parser/read/style.dart';

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

final RegExp tagNameRe = RegExp(
  '^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*',
  multiLine: true,
);

final RegExp tagNameEndRe = RegExp('(\\s|\\/|>)');

final RegExp attributeNameEndRe = RegExp('[\\s=\\/>"\']');

final RegExp attributeValueEndRe = RegExp('(\\/>|[\\s"\'=<>`])');

final RegExp quoteRe = RegExp('["\']');

final RegExp componentRe = RegExp('^[A-Z]', multiLine: true);

final RegExp textAreaEndRe = RegExp(
  '^<\\/textarea(\\s[^>]*)?>',
  caseSensitive: false,
  multiLine: true,
);

final RegExp svelteSelfRe = RegExp(
  '^svelte:self(?=[\\s/>])',
  multiLine: true,
);

final RegExp svelteComponentRe = RegExp(
  '^svelte:component(?=[\\s/>])',
  multiLine: true,
);

final RegExp svelteElementRe = RegExp(
  '^svelte:element(?=[\\s/>])',
  multiLine: true,
);

final RegExp svelteFragmentRe = RegExp(
  '^svelte:fragment(?=[\\s/>])',
  multiLine: true,
);

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

bool parentIsHead(List<BaseNode> stack) {
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

bool nodeIsThisAttribute(Node node) {
  return node.type == 'Attribute' && node.name == 'this';
}

extension TagScanner on Parser {
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

  bool readAttributeTo(List<BaseNode> attributes, Set<String> uniqueNames) {
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

    List<Node>? values;

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
      Expression? expression;

      if (values != null && values.isNotEmpty) {
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
          raw: '',
          data: '',
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
        var data = decodeCharacterReferences(raw);

        chunks.add(Node(
          start: textStart,
          end: end,
          type: 'Text',
          raw: raw,
          data: data,
        ));
      }
    }

    while (isNotDone) {
      var start = position;

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

        flush(position - 1);
        allowSpace();

        var expression = readExpression();
        allowSpace();
        expect('}');

        chunks.add(Node(
          start: start,
          end: position,
          type: 'MustacheTag',
          expression: expression,
        ));

        textStart = position;
      } else {
        position += 1;
      }
    }

    return chunks;
  }

  void tag() {
    var start = position;
    expect('<');

    if (scan('!--')) {
      // TODO(parser): parse comment ignores
      var data = readUntil('-->');
      var ignores = extractSvelteIgnore(data);
      expect('-->', unclosedComment);

      current.children!.add(Node(
        start: start,
        end: position,
        type: 'Comment',
        data: data,
        ignores: ignores,
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
        var children = parent.children;

        if ((name == 'svelte:window' || name == 'svelte:body') &&
            children != null &&
            children.isNotEmpty) {
          invalidElementContent(slug, name, children.first.start);
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

    var element = Node(
      start: start,
      type: type,
      name: name,
      children: <Node>[],
    );

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

      parent.end = position;
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

    element.attributes = attributes;

    if (name == 'svelte:component') {
      var index = attributes.indexWhere(nodeIsThisAttribute);

      if (index == -1) {
        missingComponentDefinition(start);
      }

      var definition = attributes.removeAt(index);
      var values = definition.values;

      if (values == null || values.length != 1 || values.first.type == 'Text') {
        invalidComponentDefinition(definition.start);
      }

      element.expression = values.first.expression;
    }

    if (name == 'svelte:element') {
      var index = attributes.indexWhere(nodeIsThisAttribute);

      if (index == -1) {
        missingElementDefinition(start);
      }

      var definition = attributes.removeAt(index);
      var values = definition.values;

      if (values == null || values.isEmpty) {
        invalidElementDefinition(definition.start);
      }

      element.tag = values.first.data ?? values.first.expression;
    }

    if ((name == 'script' || name == 'style') && stack.length == 1) {
      expect('>');

      if (name == 'script') {
        script(start, attributes);
      } else {
        style(start, attributes);
      }

      return;
    }

    current.children!.add(element);

    var selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      element.end = position;
    } else if (name == 'textarea') {
      element.children = readSequence(textAreaEndRe, 'inside <textarea>');
      expect(textAreaEndRe);
      element.end = position;
    } else {
      stack.add(element);
    }
  }
}
