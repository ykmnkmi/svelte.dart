import 'package:analyzer/dart/ast/ast.dart' show Expression, SimpleIdentifier;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/standard_ast_factory.dart' show astFactory;
import 'package:analyzer/dart/ast/token.dart' show Token, TokenType;

import '../parse.dart';
import '../../interface.dart';
import '../../parse/errors.dart';
import '../../parse/read/expression.dart';
import '../../parse/read/script.dart';
import '../../parse/read/style.dart';
import '../../utils/html.dart';
import '../../utils/names.dart';
import '../../utils/patterns.dart';

extension TagParser on Parser {
  static late final RegExp validTagNameRe = compile(r'^\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\-]*');

  static const Map<String, String> metaTags = <String, String>{
    'svelte:head': 'Head',
    'svelte:options': 'Options',
    'svelte:window': 'Window',
    'svelte:body': 'Body',
  };

  static const Set<String> validMetaTags = <String>{
    'svelte:head',
    'svelte:options',
    'svelte:window',
    'svelte:body',
    'svelte:self',
    'svelte:component',
    'svelte:fragment',
  };

  static late final RegExp selfRe = compile(r'^svelte:self(?=[\s/>])');
  static late final RegExp componentRe = compile(r'^svelte:component(?=[\s/>])');
  static late final RegExp slotRe = compile(r'^svelte:fragment(?=[\s/>])');

  static late final RegExp componentNameRe = compile('^[A-Z].*');
  static late final RegExp tagNameRe = compile(r'(\s|\/|>)');
  static late final RegExp attributeNameRe = compile(r'[\s=\/>"' ']');
  static late final RegExp quoteRe = compile(r'["' "']");
  static late final RegExp attributeValueEndRe = compile(r'(\/>|[\s"' "'=<>`])");

  static String? getDirectiveType(String name) {
    switch (name) {
      case 'use':
        return 'Action';
      case 'animate':
        return 'Animation';
      case 'bind':
        return 'Binding';
      case 'class':
        return 'Class';
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

  bool parentIsHead() {
    for (Node node in stack.reversed) {
      String type = node.type;

      if (type == 'Head') {
        return true;
      }

      if (type == 'Element' || type == 'InlineComponent') {
        return false;
      }
    }

    return false;
  }

  void tag() {
    int start = index;
    expect('<');
    Node parent = current;

    if (scan('!--')) {
      String data = readUntil('-->');
      expect('-->', unclosedComment);
      current.addChild(Node(start: start, end: index, type: 'Comment', data: data));
      return;
    }

    bool isClosingTag = scan('/');
    String name = readTagName();
    String? slug = metaTags[name];

    if (slug != null) {
      slug = slug.toLowerCase();

      if (isClosingTag) {
        if ((name == 'svelte:window' || name == 'svelte:body') && current.children.isNotEmpty) {
          invalidElementContent(slug, name, current.children.first.start);
        }
      } else {
        if (this.metaTags.contains(name)) {
          duplicateElement(slug, name, start);
        }

        if (stack.length > 1) {
          invalidElementPlacement(slug, name, start);
        }

        this.metaTags.add(name);
      }
    }

    String? type = metaTags[name];

    if (type == null) {
      if (componentNameRe.hasMatch(name) || name == 'svelte:self' || name == 'svelte:component') {
        type = 'InlineComponent';
      } else if (name == 'svelte:fragment') {
        type = 'SlotTemplate';
      } else if (name == 'title' && parentIsHead()) {
        type = 'Title';
      } else if (name == 'slot') {
        type = 'Slot';
      } else {
        type = 'Element';
      }
    }

    Node element = Node(start: start, type: type, name: name);
    allowWhitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        invalidVoidContent(name, start);
      }

      expect('>');
      LastAutoClosedTag? lastClosedTag = lastAutoClosedTag;

      while (parent.name != name) {
        if (parent.type != 'Element') {
          if (lastClosedTag != null && lastClosedTag.tag == name) {
            invalidClosingTagAutoclosed(name, lastClosedTag.reason, start);
          }

          invalidClosingTagUnopened(name, start);
        }

        parent.end = start;
        stack.removeLast();
        parent = current;
      }

      parent.end = index;
      stack.removeLast();

      if (lastClosedTag != null && stack.length < lastClosedTag.depth) {
        lastAutoClosedTag = null;
      }

      return;
    }

    if (closingTagOmitted(parent.name, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(name, name, stack.length);
    }

    Set<String> uniqueNames = <String>{};
    Node? attribute = readAttribute(uniqueNames);

    while (attribute != null) {
      element.addAttribute(attribute);
      allowWhitespace();
      attribute = readAttribute(uniqueNames);
    }

    if (name == 'svelte:component') {
      Node definition;

      component:
      {
        List<Node>? attributes = element.attributes;

        if (attributes != null) {
          for (Node attribute in attributes) {
            if (attribute.type == 'Attribute' && attribute.name == 'this') {
              definition = attribute;
              break component;
            }
          }
        }

        missingComponentDefinition(start);
      }

      List<Node> children = definition.children;

      if (children.length != 1 || children.first.type == 'Text') {
        invalidComponentDefinition(definition.start);
      }

      element.source = children.first.source;
    }

    if (stack.length == 1) {
      void Function(int start, List<Node>? attributes)? special;

      if (name == 'script') {
        special = script;
      } else if (name == 'style') {
        special = style;
      }

      if (special != null) {
        expect('>');
        special(start, element.attributes);
        return;
      }
    }

    current.addChild(element);
    bool selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      element.end = index;
    } else if (name == 'textarea') {
      RegExp pattern = compile(r'^<\/textarea(\s[^>]*)?>');
      element.children = readSequence(pattern);
      scan(pattern);
      element.end = index;
    } else if (name == 'script' || name == 'style') {
      int start = index;
      String data = readUntil('</$name>');
      element.addChild(Node(start: start, end: index, type: 'Text', data: data));
      expect('</$name>');
      element.end = index;
    } else {
      stack.add(element);
    }
  }

  String readTagName() {
    int start = index;

    if (scan(selfRe)) {
      for (Node fragment in stack.reversed) {
        String type = fragment.type;

        if (type == 'IfBlock' || type == 'EachBlock' || type == 'InlineComponent') {
          return 'svelte:self';
        }
      }

      invalidSelfPlacement(start);
    }

    if (scan(componentRe)) {
      return 'svelte:component';
    }

    if (scan(slotRe)) {
      return 'svelte:fragment';
    }

    String name = readUntil(tagNameRe);
    String? meta = metaTags[name];

    if (meta != null) {
      return meta;
    }

    if (name.startsWith('svelte:')) {
      invalidTagNameSvelteElement(validMetaTags, start);
    }

    if (!validTagNameRe.hasMatch(name)) {
      invalidTagName(start);
    }

    return name;
  }

  Node? readAttribute(Set<String> uniqueNames) {
    int start = index;

    void checkUnique(String name) {
      if (uniqueNames.contains(name)) {
        duplicateAttribute(start);
      }

      uniqueNames.add(name);
    }

    if (scan('{')) {
      allowWhitespace();

      if (scan('...')) {
        Expression expression = readExpression();
        allowWhitespace();
        expect('}');
        return Node(start: start, end: index, type: 'Spread', source: expression);
      } else {
        int valueStart = index;
        String? name = readIdentifier();
        allowWhitespace();
        expect('}');

        if (name == null) {
          emptyAttributeShorthand(start);
        }

        checkUnique(name);
        TokenType tokenType = TokenType(name, 'IDENTIFIER', 0, 97);
        Token token = Token(tokenType, valueStart);
        SimpleIdentifier identifier = astFactory.simpleIdentifier(token);
        int end = valueStart + name.length;
        Node shortHand = Node(start: valueStart, end: end, type: 'AttributeShorthand', source: identifier);
        return Node(start: start, end: index, type: 'Attribute', name: name, children: <Node>[shortHand]);
      }
    }

    String name = readUntil(attributeNameRe);

    if (name.isEmpty) {
      return null;
    }

    int end = index;
    allowWhitespace();
    int colonIndex = name.indexOf(':');
    String? type;

    if (colonIndex != -1) {
      type = getDirectiveType(name.substring(0, colonIndex));
    }

    List<Node>? value;

    if (scan('=')) {
      allowWhitespace();
      value = readAttributeValue();
      end = index;
    } else if (match(quoteRe)) {
      unexpectedToken('=', start);
    }

    if (type != null) {
      List<String> modifiers = name.substring(colonIndex + 1).split('|');
      String directiveName = modifiers.removeAt(0);

      if (directiveName.isEmpty) {
        emptyDirectiveName(type, start + colonIndex + 1);
      }

      if (type == 'Binding' || directiveName != 'this') {
        checkUnique(directiveName);
      } else if (type != 'Eventhandler' || type != 'Action') {
        checkUnique(directiveName);
      }

      if (type == 'Ref') {
        invalidRefDirective(name, start);
      }

      if (value != null && value.isNotEmpty) {
        if (value.length > 1 || value.first.type == 'Text') {
          invalidDirectiveValue(value.first.start);
        }
      }

      Node directive = Node(start: start, end: end, type: type, name: directiveName, modifiers: modifiers);

      if (value != null && value.isNotEmpty) {
        directive.source = value.first.source;
      }

      if (type == 'Transition') {
        String direction = name.substring(0, colonIndex);
        directive.intro = direction == 'in' || direction == 'transition';
        directive.outro = direction == 'out' || direction == 'transition';
      }

      if (value == null && (type == 'Binding' || type == 'Class')) {
        TokenType tokenType = TokenType(directiveName, 'IDENTIFIER', 0, 97);
        Token token = Token(tokenType, directive.start! + colonIndex + 1);
        directive.source = astFactory.simpleIdentifier(token);
      }

      return directive;
    }

    checkUnique(name);
    return Node(start: start, end: end, type: 'Attribute', name: name, children: value);
  }

  List<Node> readAttributeValue() {
    String? quoteMark = read(quoteRe);

    if (quoteMark != null && scan(quoteMark)) {
      return <Node>[Node(start: index - 1, end: index - 1, type: 'Text')];
    }

    Pattern regex = quoteMark ?? attributeValueEndRe;
    // TODO(error): test for unclosedAttributeValue
    List<Node> value = readSequence(regex);

    if (value.isEmpty && quoteMark == null) {
      missingAttributeValue();
    }

    if (quoteMark != null) {
      expect(quoteMark);
    }

    return value;
  }

  List<Node> readSequence(Pattern pattern) {
    StringBuffer buffer = StringBuffer();
    List<Node> chunks = <Node>[];

    void flush(int start, int end) {
      if (buffer.isNotEmpty) {
        chunks.add(Node(start: start, end: end, type: 'Text', data: buffer.toString()));
        buffer.clear();
      }
    }

    while (canParse) {
      int start = index;

      if (match(pattern)) {
        flush(start, index);
        return chunks;
      }

      if (scan('{')) {
        flush(start, index - 1);
        allowWhitespace();
        Expression expression = readExpression();
        allowWhitespace();
        expect('}');
        chunks.add(Node(start: start, end: index, type: 'MustacheTag', source: expression));
      } else {
        buffer.writeCharCode(readChar());
      }
    }

    unexpectedEOF();
  }
}
