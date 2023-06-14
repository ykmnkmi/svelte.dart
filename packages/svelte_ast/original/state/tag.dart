import 'package:analyzer/dart/ast/ast.dart' show Expression;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/extract_svelte_ignore.dart';
import 'package:svelte_ast/src/html.dart';
import 'package:svelte_ast/src/names.dart';
import 'package:svelte_ast/src/patterns.dart';

import '../parser.dart';
import '../read/expression.dart';

final RegExp _self = RegExp('^svelte:self(?=[\\s/>])');

final RegExp _component = RegExp('^svelte:component(?=[\\s/>])');

final RegExp _element = RegExp('^svelte:element(?=[\\s/>])');

final RegExp _slot = RegExp('^svelte:fragment(?=[\\s/>])');

final RegExp _validTagNameRe = RegExp('^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*');

final RegExp _tagNameEndRe = RegExp('(\\s|\\/|>)');

final RegExp _capitalLetter = RegExp('^[A-Z]');

final RegExp _nonCharRe = RegExp('[^A-Za-z]');

final RegExp _closingTextAreaTag =
    RegExp('<\\/textarea(\\s[^>]*)?>', caseSensitive: false);

const Map<String, String> _metaTags = <String, String>{
  'svelte:head': 'Head',
  'svelte:options': 'Options',
  'svelte:window': 'Window',
  'svelte:document': 'Document',
  'svelte:body': 'Body',
};

bool _parentIsHead(List<Node> stack) {
  for (Node node in stack.reversed) {
    if (node is Head) {
      return true;
    }

    if (node is Element || node is InlineComponent) {
      return true;
    }
  }

  return false;
}

extension TagParser on Parser {
  String _readTagName() {
    int start = position;

    if (scan(_self)) {
      bool legal = false;

      for (Node node in stack.reversed) {
        if (node is IfBlock || node is EachBlock || node is InlineComponent) {
          legal = true;
          break;
        }
      }

      if (!legal) {
        error(invalidSelfPlacement, start);
      }

      return 'svelte:self';
    }

    if (scan(_component)) {
      return 'svelte:component';
    }

    if (scan(_element)) {
      return 'svelte:element';
    }

    if (scan(_slot)) {
      return 'svelte:fragment';
    }

    String name = readUntil(_tagNameEndRe);

    if (_metaTags.containsKey(name)) {
      return name;
    }

    if (_validTagNameRe.hasMatch(name)) {
      return name;
    }

    error(invalidTagName, start);
  }

  List<Node> readSequence(Pattern end, String location) {
    int start = position;
    List<Node> chunks = <Node>[];

    void flush(int end) {
      if (start < end) {
        String raw = string.substring(start, end);
        String data = decodeCharacterReferences(raw, true);

        chunks.add(Text(
          start: start,
          end: end,
          raw: raw,
          data: data,
        ));

        start = end;
      }
    }

    while (isNotDone) {
      if (match(end)) {
        flush(position);
        return chunks;
      }

      if (scan('{')) {
        if (match('#')) {
          int start = position - 1;
          skip('#');

          String name = readUntil(_nonCharRe);
          error(invalidLogicBlockPlacement(location, name), start);
        } else if (match('@')) {
          int start = position - 1;
          skip('#');

          String name = readUntil(_nonCharRe);
          error(invalidTagPlacement(location, name), start);
        }

        flush(position - 1);
        allowSpace();

        Expression expression = readExpression(closingCurlyBrace);
        allowSpace();
        expect('}');

        chunks.add(MustacheTag(
          start: start,
          end: position,
          expression: expression,
        ));

        start = position;
      } else {
        position += 1;
      }
    }

    error(unexpectedEOF);
  }

  void tag() {
    int start = position;
    expect('<');

    if (scan('!--')) {
      String? data = readUntil('-->');
      expect('-->', unclosedComment);

      current.children.add(CommentTag(
        start: start,
        end: position,
        data: data,
        ignores: extractSvelteIgnore(data),
      ));

      return;
    }

    Node parent = current;
    bool isClosingTag = scan('/');
    String name = _readTagName();

    if (_metaTags[name] case String metaTag?) {
      String slug = metaTag.toLowerCase();

      if (isClosingTag) {
        if ((name == 'svelte:window' || name == 'svelte:body') &&
            current.children.isNotEmpty) {
          error(invalidElementContent(slug, name), current.children[0].start);
        }
      } else {
        if (metaTags.contains(name)) {
          error(duplicateElement(slug, name), start);
        }

        if (stack.length > 1) {
          error(invalidElementPlacement(slug, name), start);
        }

        metaTags.add(name);
      }
    }

    Node element;

    if (_capitalLetter.hasMatch(name) ||
        name == 'svelte:self' ||
        name == 'svelte:component') {
      throw UnimplementedError('InlineComponent');
    } else if (name == 'svelte:fragment') {
      throw UnimplementedError('SlotTemplate');
    } else if (name == 'title' && _parentIsHead(stack)) {
      throw UnimplementedError('Title');
    } else if (name == 'slot' && !customElement) {
      throw UnimplementedError('Slot');
    } else {
      element = Element(
        start: start,
        name: name,
        attributes: <Attribute>[],
        children: <Node>[],
      );
    }

    allowSpace();

    if (isClosingTag) {
      if (isVoid(name)) {
        error(invalidVoidContent(name), start);
      }

      expect('>');

      while (parent is! HasName || parent.name != name) {
        if (parent is! Element) {
          if (lastAutoCloseTag case AutoCloseTag tag? when tag.tag == name) {
            error(invalidClosingTagAutoClosed(name, tag.reason), start);
          } else {
            error(invalidClosingTagUnopened(name), start);
          }
        }

        parent.end = start;
        stack.removeLast();
        parent = current;
      }

      parent.end = position;
      stack.removeLast();

      if (lastAutoCloseTag case AutoCloseTag tag?
          when stack.length < tag.depth) {
        lastAutoCloseTag = null;
      }

      return;
    }

    if (closingTagOmitted(parent is HasName ? parent.name : null, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoCloseTag = (
        tag: parent is HasName ? parent.name : null,
        reason: name,
        depth: stack.length,
      );
    }

    if (name == 'svelte:component') {
      throw UnimplementedError('svelte:component');
    }

    if (name == 'svelte:element') {
      throw UnimplementedError('svelte:element');
    }

    // script/style

    current.children.add(element);

    bool selfClosing = scan('/') || isVoid(name);
    expect('>');

    if (selfClosing) {
      element.end = position;
    } else if (name == 'textarea') {
      element.children = readSequence(_closingTextAreaTag, 'inside <textarea>');
      expect(_closingTextAreaTag);
      element.end = position;
    } else if (name == 'script' || name == 'style') {
      throw UnimplementedError('script/style');
    } else {
      stack.add(element);
    }
  }
}
