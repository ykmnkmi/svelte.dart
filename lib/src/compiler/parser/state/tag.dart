import 'package:nutty/src/compiler/ast.dart';
import 'package:nutty/src/compiler/parser/ast/attributes.dart';
import 'package:nutty/src/compiler/parser/errors.dart';
import 'package:nutty/src/compiler/parser/html.dart';
import 'package:nutty/src/compiler/parser/names.dart';
import 'package:nutty/src/compiler/parser/parser.dart';

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

final RegExp componentRe = RegExp('^[A-Z]');

final RegExp svelteSelfRe = RegExp('^svelte:self(?=[\\s/>])');

final RegExp svelteComponentRe = RegExp('^svelte:component(?=[\\s/>])');

final RegExp svelteElementRe = RegExp('^svelte:element(?=[\\s/>])');

final RegExp svelteFragmentRe = RegExp('^svelte:fragment(?=[\\s/>])');

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

  bool parentIsHead() {
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

  bool readAttribute(Element element, Set<String> uniqueNames) {
    var start = position;

    void checkunique(String name) {
      if (uniqueNames.contains(name)) {
        duplicateAttribute(start);
      }

      uniqueNames.add(name);
    }

    throw UnimplementedError();
  }

  void tag() {
    var start = position;

    expect('<');

    if (scan('!--')) {
      var text = readUntil('-->');

      expect('-->', unclosedComment);

      var node = Comment(start: start, end: position, text: text);
      current.children.add(node);
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
    } else if (name == 'title' && parentIsHead()) {
      type = 'Title';
    } else if (name == 'slot') {
      type = 'Slot';
    } else {
      type = 'Element';
    }

    var element = Element(start: start, type: type, name: name);

    allowSpace();

    if (isClosingTag) {
      if (isVoid(name)) {
        invalidVoidContent(name, start);
      }

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

    var uniqueNames = <String>{};

    while (readAttribute(element, uniqueNames)) {
      allowSpace();
    }

    // TODO(parser): svelte:component
    // TODO(parser): svelte:element
    // TODO(parser): specials

    current.children.add(element);

    var selfClosing = scan('/') || isVoid(name);

    expect('>');

    if (selfClosing) {
      element.end = position;
    } else if (name == 'textarea') {
      // TODO(parser): textarea
    } else {
      stack.add(element);
    }
  }
}
