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
    for (var node in stack.reversed) {
      var type = node.type;

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
    var start = index;
    expect('<');

    var parent = current;

    if (scan('!--')) {
      var data = readUntil('-->');
      expect('-->', onError: unclosedComment);

      var node = Node(start: start, end: index, type: 'Comment', data: data, ignores: <String>[]);
      current.children!.add(node);
      return;
    }

    var isClosingTag = scan('/');
    var name = readTagName();

    if (metaTags.containsKey(name)) {
      var slug = metaTags[name];

      if (slug != null) {
        slug = slug.toLowerCase();

        if (isClosingTag) {
          var children = current.children;

          if ((name == 'svelte:window' || name == 'svelte:body') && children != null && children.isNotEmpty) {
            invalidElementContent(slug, name, children.first.start);
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
    }

    var type = metaTags[name];

    if (type == null) {
      if (RegExp('^[A-Z]').hasMatch(name) || name == 'svelte:self' || name == 'svelte:component') {
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

    var element = Node(start: start, type: type, name: name, attributes: <Node>[], children: <Node>[]);
    allowWhitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        invalidVoidContent(name, start);
      }

      expect('>');

      var lastClosedTag = lastAutoClosedTag;

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

    var uniqueNames = <String>{};
    var attribute = readAttribute(uniqueNames);

    while (attribute != null) {
      element.attributes!.add(attribute);
      allowWhitespace();
      attribute = readAttribute(uniqueNames);
    }

    if (name == 'svelte:component') {
      var attributes = element.attributes;

      if (attributes != null) {
        var index = attributes.indexWhere((attribute) => attribute.type == 'Attribute' && attribute.name == 'this');

        if (index == -1) {
          missingComponentDefinition(start);
        }

        var definition = attributes.removeAt(index);
        var children = definition.children;

        if (children == null || children.length != 1 || children.first.type == 'Text') {
          invalidComponentDefinition(definition.start);
        }

        element.expression = children.first.expression;
      }
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

    current.children!.add(element);

    var selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      element.end = index;
    } else if (name == 'textarea') {
      var pattern = compile(r'^<\/textarea(\s[^>]*)?>');
      element.children = readSequence(pattern);
      scan(pattern);
      element.end = index;
    } else if (name == 'script' || name == 'style') {
      var start = index;
      var data = readUntil('</$name>');
      var node = Node.text(start: start, end: index, data: data);
      element.children!.add(node);
      expect('</$name>');
      element.end = index;
    } else {
      stack.add(element);
    }
  }

  String readTagName() {
    var start = index;

    if (scan(RegExp('^svelte:self(?=[\\s/>])'))) {
      for (var fragment in stack.reversed) {
        var type = fragment.type;

        if (type == 'IfBlock' || type == 'EachBlock' || type == 'InlineComponent') {
          return 'svelte:self';
        }
      }

      invalidSelfPlacement(start);
    }

    if (scan(RegExp('^svelte:component(?=[\\s/>])'))) {
      return 'svelte:component';
    }

    if (scan(RegExp('^svelte:fragment(?=[\\s/>])'))) {
      return 'svelte:fragment';
    }

    var name = readUntil(RegExp('(\\s|\\/|>)'));

    if (metaTags.containsKey(name)) {
      return metaTags[name]!;
    }

    if (name.startsWith('svelte:')) {
      invalidTagNameSvelteElement(validMetaTags, start);
    }

    if (!RegExp('^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*').hasMatch(name)) {
      invalidTagName(start);
    }

    return name;
  }

  Node? readAttribute(Set<String> uniqueNames) {
    var start = index;

    void checkUnique(String name) {
      if (uniqueNames.contains(name)) {
        duplicateAttribute(start, index);
      }

      uniqueNames.add(name);
    }

    if (scan('{')) {
      allowWhitespace();

      if (scan('...')) {
        var expression = readExpression();
        allowWhitespace();
        expect('}');
        return Node(start: start, end: index, type: 'Spread', expression: expression);
      } else {
        var valueStart = index;
        var name = readIdentifier();
        allowWhitespace();
        expect('}');

        if (name == null) {
          emptyAttributeShorthand(start);
        }

        checkUnique(name);

        var tokenType = TokenType(name, 'IDENTIFIER', 0, 97);
        var token = Token(tokenType, valueStart);
        var identifier = astFactory.simpleIdentifier(token);
        var end = valueStart + name.length;
        var shortHand = Node(start: valueStart, end: end, type: 'AttributeShorthand', expression: identifier);
        return Node(start: start, end: index, type: 'Attribute', name: name, children: <Node>[shortHand]);
      }
    }

    var name = readUntil(RegExp('[\\s=\\/>"]'));

    if (name.isEmpty) {
      return null;
    }

    var end = index;
    allowWhitespace();

    var colonIndex = name.indexOf(':');
    String? type;

    if (colonIndex != -1) {
      type = getDirectiveType(name.substring(0, colonIndex));
    }

    List<Node>? value;

    if (scan('=')) {
      allowWhitespace();
      value = readAttributeValue();
      end = index;
    } else if (match(RegExp('["\']'))) {
      unexpectedToken('=', start);
    }

    if (type != null) {
      var modifiers = name.substring(colonIndex + 1).split('|');
      var directiveName = modifiers.removeAt(0);

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

      var directive = Node(start: start, end: end, type: type, name: directiveName, modifiers: modifiers);

      if (value != null && value.isNotEmpty) {
        directive.expression = value.first.expression;
      }

      if (type == 'Transition') {
        var direction = name.substring(0, colonIndex);
        directive.intro = direction == 'in' || direction == 'transition';
        directive.outro = direction == 'out' || direction == 'transition';
      }

      if (value == null && (type == 'Binding' || type == 'Class')) {
        var tokenType = TokenType(directiveName, 'IDENTIFIER', 0, 97);
        var token = Token(tokenType, directive.start! + colonIndex + 1);
        directive.expression = astFactory.simpleIdentifier(token);
      }

      return directive;
    }

    checkUnique(name);
    return Node(start: start, end: end, type: 'Attribute', name: name, children: value);
  }

  List<Node> readAttributeValue() {
    var quoteMark = read(RegExp('["\']'));

    if (quoteMark != null && scan(quoteMark)) {
      return <Node>[Node.text(start: index - 1, end: index - 1)];
    }

    var regex = quoteMark ?? RegExp('(\\/>|[\\s"\'=<>`])');
    List<Node> value;

    value = readSequence(regex);

    if (value.isEmpty && quoteMark == null) {
      missingAttributeValue();
    }

    if (quoteMark != null) {
      expect(quoteMark);
    }

    return value;
  }

  List<Node> readSequence(Pattern pattern) {
    var buffer = StringBuffer();
    var chunks = <Node>[];

    void flush(int start, int end) {
      if (buffer.isNotEmpty) {
        var node = Node.text(start: start, end: end, data: buffer.toString());
        chunks.add(node);
        buffer.clear();
      }
    }

    while (canParse) {
      var start = index;

      if (match(pattern)) {
        flush(start, index);
        return chunks;
      }

      if (scan('{')) {
        flush(start, index - 1);
        allowWhitespace();

        var expression = readExpression();
        allowWhitespace();
        expect('}');

        var node = Node(start: start, end: index, type: 'MustacheTag', expression: expression);
        chunks.add(node);
      } else {
        buffer.writeCharCode(readChar());
      }
    }

    unexpectedEOF();
  }
}
