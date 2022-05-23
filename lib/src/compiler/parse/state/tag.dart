import 'package:analyzer/dart/ast/token.dart' show Token, TokenType;
import 'package:analyzer/src/dart/ast/ast_factory.dart' show astFactory;
import 'package:piko/src/compiler/interface.dart';
import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/html.dart';
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/parse/read/expression.dart';
import 'package:piko/src/compiler/parse/read/script.dart';
import 'package:piko/src/compiler/parse/read/style.dart';

extension TagParser on Parser {
  static const Set<String> metaTags = <String>{
    'piko:head',
    'piko:options',
    'piko:window',
    'piko:body',
  };

  static const Set<String> validMetaTags = <String>{
    'piko:head',
    'piko:options',
    'piko:window',
    'piko:body',
    'piko:self',
    'piko:component',
    'piko:fragment',
  };

  static final RegExp ignoreRe = RegExp('^\\s*ignore:\\s+([\\s\\S]+)\\s*\$', multiLine: true);

  static final RegExp componentNameRe = RegExp('^[A-Z]');

  static final RegExp selfRe = RegExp('^piko:self(?=[\\s/>])', multiLine: true);

  static final RegExp componentRe = RegExp('^piko:component(?=[\\s/>])', multiLine: true);

  static final RegExp fragmentRe = RegExp('^piko:fragment(?=[\\s/>])', multiLine: true);

  static final RegExp metaTagEndRe = RegExp('(\\s|\\/|>)');

  static final RegExp tagRe = RegExp('^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*', multiLine: true);

  static final RegExp attributeNameEndRe = RegExp('[\\s=\\/>"]');

  static final RegExp attributeValueEndRe = RegExp('(\\/>|[\\s"\'=<>`])');

  static final RegExp quoteRe = RegExp('["\']');

  static final RegExp textareaCloseTagRe = RegExp(r'^<\/textarea(\s[^>]*)?>');

  static final RegExp voidElementNames = RegExp('^(?:'
      'area|'
      'base|'
      'br|'
      'col|'
      'command|'
      'embed|'
      'hr|'
      'img|'
      'input|'
      'keygen|'
      'link|'
      'meta|'
      'param|'
      'source|'
      'track|'
      'wbr'
      ')\$');

  static bool isVoid(String name) {
    return voidElementNames.hasMatch(name) || '!doctype' == name.toLowerCase();
  }

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

  static List<String>? extractIgnore(String text) {
    var match = ignoreRe.firstMatch(text);

    if (match == null) {
      return null;
    }

    return match[1]!.split(',').map<String>((rule) => rule.trim()).where((rule) => rule.isNotEmpty).toList();
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
      addNode(Comment(start: start, end: index, data: data, ignores: extractIgnore(data)));
      return;
    }

    var isClosingTag = scan('/');
    var name = readTagName();

    if (metaTags.contains(name)) {
      // 'piko:'.length
      var slug = name.substring(5);

      if (isClosingTag) {
        // TODO(error): wrap cast
        var current = this.current as ChildrenNode;
        var children = current.children;

        if ((name == 'piko:window' || name == 'piko:body') && children.isNotEmpty) {
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

    Node node;

    if (name == 'piko:head') {
      node = Head(start: start);
    } else if (name == 'piko:options') {
      node = Options(start: start);
    } else if (name == 'piko:window') {
      node = Window(start: start);
    } else if (name == 'piko:body') {
      node = Body(start: start);
    } else if (componentNameRe.hasMatch(name) || name == 'piko:self' || name == 'piko:component') {
      node = InlineComponent(start: start, name: name);
    } else if (name == 'piko:fragment') {
      node = SlotTemplate(start: start);
    } else if (name == 'title' && parentIsHead()) {
      node = Title(start: start);
    } else if (name == 'slot') {
      node = Slot(start: start);
    } else {
      node = Element(start: start, name: name);
    }

    allowWhitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        invalidVoidContent(name, start);
      }

      expect('>');

      while (parent is! NamedNode || parent.name != name) {
        if (parent is! Element) {
          if (lastAutoClosedTag != null && lastAutoClosedTag!.tag == name) {
            invalidClosingTagAutoclosed(name, lastAutoClosedTag!.reason, start);
          }

          invalidClosingTagUnopened(name, start);
        }

        parent.end = start;
        parent = stack.removeLast();
      }

      parent.end = index;
      stack.removeLast();

      if (lastAutoClosedTag != null && stack.length < lastAutoClosedTag!.depth) {
        lastAutoClosedTag = null;
      }

      return;
    }

    if (parent is NamedNode && closingTagOmitted(parent.name, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(parent.name, name, stack.length);
    }

    var uniqueNames = <String>{};

    while (readAttribute(node, uniqueNames)) {
      allowWhitespace();
    }

    if (name == 'piko:component') {
      var attributeNode = node as AttributeNode;
      var attributes = attributeNode.attributes;
      var index = attributes.indexWhere((attribute) => attribute is Attribute && attribute.name == 'this');

      if (index == -1) {
        missingComponentDefinition(start);
      }

      var definition = attributes.removeAt(index) as ChildrenNode;
      var children = definition.children;

      if (children.length != 1 || children.first.type == 'Text') {
        invalidComponentDefinition(definition.start);
      }

      var expressionNode = node as ExpressionNode;
      var first = children.first as ExpressionNode;
      expressionNode.expression = first.expression;
    }

    if (stack.length == 1) {
      void Function(int start, List<Node> attributes)? special;

      if (name == 'script') {
        special = script;
      } else if (name == 'style') {
        special = style;
      }

      if (special != null) {
        var attributeNode = node as AttributeNode;
        expect('>');
        special(start, attributeNode.attributes);
        return;
      }
    }

    addNode(node);

    var selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      node.end = index;
    } else if (name == 'textarea') {
      var childrenNode = node as ChildrenNode;
      childrenNode.children = readSequence(textareaCloseTagRe);
      scan(textareaCloseTagRe);
      childrenNode.end = index;
    } else if (name == 'script' || name == 'style') {
      var childrenNode = node as ChildrenNode;
      var start = index;
      var data = readUntil('</$name>');
      var text = Text(start: start, end: index, data: data);
      childrenNode.children.add(text);
      expect('</$name>');
      childrenNode.end = index;
    } else {
      stack.add(node);
    }
  }

  String readTagName() {
    var start = index;

    if (scan(selfRe)) {
      for (var fragment in stack.reversed) {
        if (fragment is IfBlock || fragment is EachBlock || fragment is InlineComponent) {
          return 'piko:self';
        }
      }

      invalidSelfPlacement(start);
    }

    if (scan(componentRe)) {
      return 'piko:component';
    }

    if (scan(fragmentRe)) {
      return 'piko:fragment';
    }

    var name = readUntil(metaTagEndRe);

    if (metaTags.contains(name)) {
      return name;
    }

    if (name.startsWith('piko:')) {
      invalidTagNameSvelteElement(validMetaTags, start);
    }

    if (!tagRe.hasMatch(name)) {
      invalidTagName(start);
    }

    return name;
  }

  bool readAttribute(Node node, Set<String> uniqueNames) {
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
        var attributeNode = node as AttributeNode;
        var expression = readExpression();
        allowWhitespace();
        expect('}');
        attributeNode.attributes.add(Spread(start: start, end: index, expression: expression));
        return true;
      } else {
        var attributeNode = node as AttributeNode;
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
        attributeNode.attributes.add(Attribute(start: start, end: index, name: name, children: <Node>[shortHand]));
        return true;
      }
    }

    var name = readUntil(attributeNameEndRe);

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
      values = readAttributeValues();
      end = index;
    } else if (match(quoteRe)) {
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

      var attributeNode = node as AttributeNode;
      attributeNode.attributes.add(directive);
      return true;
    }

    var attributeNode = node as AttributeNode;
    checkUnique(name);
    attributeNode.attributes.add(Attribute(start: start, end: end, name: name, children: values));
    return true;
  }

  List<Node> readAttributeValues() {
    var quoteMark = read(quoteRe);

    if (quoteMark != null && scan(quoteMark)) {
      return <Node>[Text(start: index - 1, end: index - 1, data: '')];
    }

    var regex = quoteMark ?? attributeValueEndRe;
    List<Node> values;

    try {
      values = readSequence(regex);
    } on CompileError catch (error) {
      index = error.span.start.offset;
      unclosedAttributeValue(quoteMark ?? '}');
    }

    if (values.isEmpty && quoteMark == null) {
      missingAttributeValue();
    }

    if (quoteMark != null) {
      expect(quoteMark);
    }

    return values;
  }

  List<Node> readSequence(Pattern pattern) {
    var buffer = StringBuffer();
    var chunks = <Node>[];
    var textStart = index;

    void flush(int end) {
      if (buffer.isNotEmpty) {
        chunks.add(Text(start: textStart, end: end, data: decodeCharacterReferences(buffer.toString())));
        buffer.clear();
      }
    }

    while (canParse) {
      if (match(pattern)) {
        flush(index);
        return chunks;
      }

      if (scan('{')) {
        var start = index - 1;
        flush(start);
        allowWhitespace();

        var expression = readExpression();
        allowWhitespace();
        expect('}');
        chunks.add(Mustache(start: start, end: index, expression: expression));
        textStart = index;
      } else {
        buffer.writeCharCode(readChar());
      }
    }

    unexpectedEOF();
  }
}
