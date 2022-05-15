import 'package:analyzer/dart/ast/token.dart' show Token, TokenType;
import 'package:analyzer/src/dart/ast/ast_factory.dart' show astFactory;
import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/parse/read/expression.dart';
import 'package:piko/src/compiler/parse/read/script.dart';
import 'package:piko/src/compiler/parse/read/style.dart';
import 'package:piko/src/compiler/utils/html.dart';
import 'package:piko/src/compiler/utils/names.dart';

extension TagParser on Parser {
  static const Map<String, ElementFactory> metaTags = <String, ElementFactory>{
    'svelte:head': Head.new,
    'svelte:options': Options.new,
    'svelte:window': Window.new,
    'svelte:body': Body.new,
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
      addNode(Comment(start: start, end: index, data: data));
      return;
    }

    var isClosingTag = scan('/');
    var name = readTagName();

    if (metaTags.containsKey(name)) {
      var slug = name.substring('svelte:'.length);

      if (isClosingTag) {
        // TODO(error): wrap cast
        var current = this.current as MultiChildNode;
        var children = current.children;

        if ((name == 'svelte:window' || name == 'svelte:body') && children.isNotEmpty) {
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

    var type = metaTags[name];
    Element element;

    if (type == null) {
      if (RegExp('^[A-Z]').hasMatch(name) || name == 'svelte:self' || name == 'svelte:component') {
        element = InlineComponent(start: start);
      } else if (name == 'svelte:fragment') {
        element = SlotTemplate(start: start);
      } else if (name == 'title' && parentIsHead()) {
        element = Title(start: start);
      } else if (name == 'slot') {
        element = Slot(start: start);
      } else {
        element = Element(start: start, name: name);
      }
    } else {
      element = type(start: start);
    }

    allowWhitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        invalidVoidContent(name, start);
      }

      expect('>');

      var lastClosedTag = lastAutoClosedTag;

      while (parent is NamedNode && parent.name != name) {
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

    if (parent is NamedNode && closingTagOmitted(parent.name, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(name, name, stack.length);
    }

    var uniqueNames = <String>{};

    while (readAttributeOrDirective(element, uniqueNames)) {
      allowWhitespace();
    }

    if (name == 'svelte:component') {
      var attributes = element.attributes;
      var index = attributes.indexWhere((attribute) => attribute.type == 'Attribute' && attribute.name == 'this');

      if (index == -1) {
        missingComponentDefinition(start);
      }

      var definition = attributes.removeAt(index);
      var children = definition.children;

      if (children.length != 1 || children.first.type == 'Text') {
        invalidComponentDefinition(definition.start);
      }

      // TODO(error): wrap cast
      var expressionNode = element as ExpressionNode;
      var first = children.first as ExpressionNode;
      expressionNode.expression = first.expression;
    }

    if (stack.length == 1) {
      void Function(int start, List<Attribute> attributes)? special;

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

    addNode(element);

    var selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      element.end = index;
    } else if (name == 'textarea') {
      // TODO(parser): check ^<\/textarea(\s[^>]*)?>
      var pattern = RegExp(r'<\/textarea(\s[^>]*)?>');
      element.children = readSequence(pattern);
      scan(pattern);
      element.end = index;
    } else if (name == 'script' || name == 'style') {
      var start = index;
      var data = readUntil('</$name>');
      var node = Text(start: start, end: index, data: data);
      element.children.add(node);
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
      return name;
    }

    if (name.startsWith('svelte:')) {
      invalidTagNameSvelteElement(validMetaTags, start);
    }

    if (!RegExp('^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*').hasMatch(name)) {
      invalidTagName(start);
    }

    return name;
  }

  bool readAttributeOrDirective(Element element, Set<String> uniqueNames) {
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
        element.attributes.add(Spread(start: start, end: index, expression: expression));
        return true;
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
        var shortHand = AttributeShorthand(start: valueStart, end: end, expression: identifier);
        element.attributes.add(Attribute(start: start, end: index, name: name, children: <Node>[shortHand]));
        return true;
      }
    }

    var name = readUntil(RegExp('[\\s=\\/>"]'));

    if (name.isEmpty) {
      return false;
    }

    var end = index;
    allowWhitespace();

    var colonIndex = name.indexOf(':');
    String? type;

    if (colonIndex != -1) {
      type = getDirectiveType(name.substring(0, colonIndex));
    }

    List<Node>? values;

    if (scan('=')) {
      allowWhitespace();
      values = readAttributeOrDirectiveValues();
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

      if (type == 'Binding' && directiveName != 'this') {
        checkUnique(directiveName);
      } else if (type != 'EventHandler' && type != 'Action') {
        checkUnique(directiveName);
      }

      if (type == 'Ref') {
        invalidRefDirective(name, start);
      }

      if (values != null && (values.length > 1 || values.first is Text)) {
        invalidDirectiveValue(values.first.start);
      }

      var directive = Directive(start: start, end: end, type: type, name: directiveName, modifiers: modifiers);

      if (values != null && values.isNotEmpty) {
        var first = values.first;

        if (first is ExpressionNode) {
          directive.expression = first.expression;
        }
      }

      if (type == 'Transition') {
        var direction = name.substring(0, colonIndex);
        directive.intro = direction == 'in' || direction == 'transition';
        directive.outro = direction == 'out' || direction == 'transition';
      }

      if (values == null && (type == 'Binding' || type == 'Class')) {
        var tokenType = TokenType(directiveName, 'IDENTIFIER', 0, 97);
        var token = Token(tokenType, directive.start! + colonIndex + 1);
        directive.expression = astFactory.simpleIdentifier(token);
      }

      element.directives.add(directive);
      return true;
    }

    checkUnique(name);
    element.attributes.add(Attribute(start: start, end: end, name: name, children: values));
    return true;
  }

  List<Node> readAttributeOrDirectiveValues() {
    var quoteMark = read(RegExp('["\']'));

    if (quoteMark != null && scan(quoteMark)) {
      return <Node>[Text(start: index - 1, end: index - 1, data: '')];
    }

    var regex = quoteMark ?? RegExp('(\\/>|[\\s"\'=<>`])');
    var value = readSequence(regex);

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
        chunks.add(Text(start: start, end: end, data: buffer.toString()));
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
        chunks.add(Mustache(start: start, end: index, expression: expression));
      } else {
        buffer.writeCharCode(readChar());
      }
    }

    unexpectedEOF();
  }
}
