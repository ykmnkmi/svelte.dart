// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/scanner/token.dart' show StringToken;
import 'package:analyzer/dart/ast/token.dart' show TokenType;
import 'package:analyzer/src/dart/ast/ast_factory.dart' show astFactory;
import 'package:nutty/src/compiler/interface.dart';
import 'package:nutty/src/compiler/parser/errors.dart';
import 'package:nutty/src/compiler/parser/extract_ignore.dart';
import 'package:nutty/src/compiler/parser/html.dart';
import 'package:nutty/src/compiler/parser/names.dart';
import 'package:nutty/src/compiler/parser/parse.dart';
import 'package:nutty/src/compiler/parser/read/expression.dart';
import 'package:nutty/src/compiler/parser/read/script.dart';
import 'package:nutty/src/compiler/parser/read/style.dart';

extension TagParser on Parser {
  static const Map<String, String> metaTags = <String, String>{
    'head': 'Head',
    'options': 'Options',
    'window': 'Window',
    'body': 'Body',
  };

  static const Set<String> validMetaTags = <String>{
    'head',
    'options',
    'window',
    'body',
    'self',
    'component',
    'fragment',
    'element',
  };

  static final RegExp componentNameRe = RegExp('^[A-Z]');

  static final RegExp textareaCloseTagRe = RegExp(r'^<\/textarea(\s[^>]*)?>');

  static final RegExp selfRe = RegExp('^self(?=[\\s/>])', multiLine: true);

  static final RegExp elementRe = RegExp('^element(?=[\\s/>])');

  static final RegExp componentRe =
      RegExp('^component(?=[\\s/>])', multiLine: true);

  static final RegExp fragmentRe =
      RegExp('^fragment(?=[\\s/>])', multiLine: true);

  static final RegExp metaTagEndRe = RegExp('(\\s|\\/|>)');

  static final RegExp tagRe =
      RegExp('^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*', multiLine: true);

  static final RegExp attributeNameEndRe = RegExp('[\\s=\\/>"]');

  static final RegExp attributeValueEndRe = RegExp('(\\/>|[\\s"\'=<>`])');

  static final RegExp quoteRe = RegExp('["\']');

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

  static bool parentIsHead(List<Node> stack) {
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

  String readTagName() {
    var start = index;

    if (scan(selfRe)) {
      for (var node in stack.reversed) {
        if (node.type == 'IfBlock' ||
            node.type == 'EachBlock' ||
            node.type == 'InlineComponent') {
          return 'self';
        }
      }

      invalidSelfPlacement(start);
    }

    if (scan(componentRe)) {
      return 'component';
    }

    if (scan(elementRe)) {
      return 'element';
    }

    if (scan(fragmentRe)) {
      return 'fragment';
    }

    var name = readUntil(metaTagEndRe);

    if (metaTags.containsKey(name)) {
      return name;
    }

    if (tagRe.hasMatch(name)) {
      return name;
    }

    invalidTagName(start);
  }

  List<Node> readAttributeValues() {
    var quoteMark = read(quoteRe);

    if (quoteMark != null && scan(quoteMark)) {
      return <Node>[Text(start: index - 1, end: index - 1, raw: '', data: '')];
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

  bool readAttribute(Element element, Set<String> uniqueNames) {
    var start = index;

    void checkUnique(String name) {
      if (uniqueNames.contains(name)) {
        duplicateAttribute(start, index);
      }

      uniqueNames.add(name);
    }

    if (scan('{')) {
      allowSpace();

      if (scan('...')) {
        var expression = readExpression();
        element.attributes
            .add(Spread(start: start, end: index, expression: expression));
        allowSpace();
        expect('}');
        return true;
      } else {
        var valueStart = index;
        var name = readIdentifier();
        allowSpace();
        expect('}');

        if (name == null) {
          emptyAttributeShorthand(start);
        }

        checkUnique(name);

        var token = StringToken(TokenType.IDENTIFIER, name, valueStart);
        var identifier = astFactory.simpleIdentifier(token);
        var end = valueStart + name.length;
        var shortHand =
            Shorthand(start: valueStart, end: end, expression: identifier);
        element.attributes.add(Attribute(
            start: start, end: index, name: name, children: <Node>[shortHand]));
        return true;
      }
    }

    var name = readUntil(attributeNameEndRe);

    if (name.isEmpty) {
      return false;
    }

    var end = index;
    allowSpace();

    var colonIndex = name.indexOf(':');

    String? type;

    if (colonIndex != -1) {
      type = getDirectiveType(name.substring(0, colonIndex));
    }

    if (match(quoteRe)) {
      unexpectedToken('=', start);
    }

    List<Node>? values;

    if (scan('=')) {
      allowSpace();
      values = readAttributeValues();
      end = index;
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

      if (type == 'StyleDirective') {
        element.attributes.add(Directive(
            start: start,
            end: end,
            type: type,
            name: directiveName,
            children: values));
        return true;
      }

      var directive = Directive(
          start: start,
          end: end,
          type: type,
          name: directiveName,
          modifiers: modifiers);

      if (values != null && values.isNotEmpty) {
        if (values.length > 1 || values.first is Text) {
          invalidDirectiveValue(values.first.start);
        }

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

      if (directive.expression == null &&
          (type == 'Binding' || type == 'Class')) {
        var token = StringToken(TokenType.IDENTIFIER, directiveName,
            directive.start! + colonIndex + 1);
        directive.expression = astFactory.simpleIdentifier(token);
      }

      element.attributes.add(directive);
      return true;
    }

    checkUnique(name);
    element.attributes
        .add(Attribute(start: start, end: end, name: name, children: values));
    return true;
  }

  List<Node> readSequence(Pattern pattern) {
    var buffer = StringBuffer();
    var chunks = <Node>[];
    var textStart = index;

    void flush(int end) {
      if (buffer.isNotEmpty) {
        var data = buffer.toString();
        chunks.add(Text(
            start: textStart,
            end: end,
            raw: data,
            data: decodeCharacterReferences(data)));
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
        allowSpace();

        var expression = readExpression();
        allowSpace();
        expect('}');
        chunks.add(Mustache(start: start, end: index, expression: expression));
        textStart = index;
      } else {
        buffer.writeCharCode(readChar());
      }
    }

    unexpectedEOF();
  }

  void tag() {
    var start = index;
    expect('<');

    var parent = current;

    if (scan('!--')) {
      var data = readUntil('-->');
      expect('-->', onError: unclosedComment);
      current.children.add(Comment(
          start: start, end: index, data: data, ignores: extractIgnore(data)));
      return;
    }

    var isClosingTag = scan('/');
    var name = readTagName();
    var type = metaTags[name];

    if (type != null) {
      var slug = type.toLowerCase();

      if (isClosingTag) {
        var children = current.children;

        if ((name == 'window' || name == 'body') && children.isNotEmpty) {
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
    } else {
      if (componentNameRe.hasMatch(name) ||
          name == 'self' ||
          name == 'component') {
        type = 'InlineComponent';
      } else if (name == 'fragment') {
        type = 'SlotTemplate';
      } else if (name == 'title' && parentIsHead(stack)) {
        type = 'Title';
      } else if (name == 'slot') {
        type = 'Slot';
      } else {
        type = 'Element';
      }
    }

    var element = Element(start: start, type: type, name: name);
    allowSpace();

    if (isClosingTag) {
      if (isVoid(name)) {
        invalidVoidContent(name, start);
      }

      expect('>');

      while (parent is! Element || parent.name != name) {
        if (parent is! Element) {
          if (lastAutoClosedTag != null && lastAutoClosedTag!.tag == name) {
            invalidClosingTagAutoClosed(name, lastAutoClosedTag!.reason, start);
          }

          invalidClosingTagUnopened(name, start);
        }

        parent.end = start;
        stack.removeLast();
        parent = current;
      }

      parent.end = index;
      stack.removeLast();

      if (lastAutoClosedTag != null &&
          stack.length < lastAutoClosedTag!.depth) {
        lastAutoClosedTag = null;
      }

      return;
    }

    if (parent is Element && closingTagOmitted(parent.name, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(parent.name, name, stack.length);
    }

    var uniqueNames = <String>{};

    while (readAttribute(element, uniqueNames)) {
      allowSpace();
    }

    if (name == 'component') {
      var attributes = element.attributes;
      var index = attributes.indexWhere(
          (attribute) => attribute is Attribute && attribute.name == 'this');

      if (index == -1) {
        missingComponentDefinition(start);
      }

      var definition = attributes.removeAt(index);
      var children = definition.children;

      if (children.length != 1 || children.first.type == 'Text') {
        invalidComponentDefinition(definition.start);
      }

      var expressionNode = element as Attribute;
      var first = children.first as Attribute;
      expressionNode.expression = first.expression;
    }

    if (name == 'element') {
      var attributes = element.attributes;
      var index = attributes.indexWhere(
          (attribute) => attribute is Attribute && attribute.name == 'this');

      if (index == -1) {
        missingElementDefinition(start);
      }

      var definition = attributes.removeAt(index);
      var children = definition.children;

      if (children.isEmpty) {
        invalidElementDefinition();
      }

      var first = children.first;

      if (first is Text) {
        element.tag = first.data;
      } else if (first is ExpressionNode) {
        element.tag = first.expression;
      }
    }

    if (stack.length == 1) {
      void Function(int start, List<Node> attributes)? special;

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

    current.children.add(element);

    var selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      element.end = index;
    } else if (name == 'textarea') {
      element.children = readSequence(textareaCloseTagRe);
      scan(textareaCloseTagRe);
      element.end = index;
    } else if (name == 'script' || name == 'style') {
      var start = index;
      var data = readUntil('</$name>');
      var text = Text(start: start, end: index, raw: data, data: data);
      element.children.add(text);
      expect('</$name>');
      element.end = index;
    } else {
      stack.add(element);
    }
  }
}
