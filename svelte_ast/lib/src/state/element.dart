import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/html.dart';
import 'package:svelte_ast/src/names.dart';
import 'package:svelte_ast/src/parser.dart';

final RegExp _tagNameEndRe = RegExp('(\\s|\\/|>)');

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
];

bool _parentIsHead(List<Node> stack) {
  for (Node node in stack.reversed) {
    if (node is SvelteHead) {
      return true;
    }

    if (node is RegularElement || node is Component) {
      return true;
    }
  }

  return false;
}

bool _parentIsShadowRootTemplate(List<Node> stack) {
  for (Node node in stack.reversed) {
    if (node is RegularElement) {
      for (Attribute attribute in node.attributes) {
        // TODO(ast): ShadowRoot: support or remove?
        if (attribute.name == 'shadowrootmode') {
          return true;
        }
      }
    }
  }

  return false;
}

extension ElementParser on Parser {
  void element() {
    int start = index;
    expect('<');

    if (scan('!--')) {
      String data = readUntil('-->');
      expect('-->');
      add(Comment(start: start, end: index, data: data));
      return;
    }

    Node parent = current;
    bool isClosingTag = scan('/');
    String name = readUntil(_tagNameEndRe);

    if (isClosingTag) {
      allowSpace();
      expect('>');

      if (isVoid(name)) {
        voidElementInvalidContent(start);
      }

      AutoClosedTag? tag = lastAutoClosedTag;

      // Closing any elements that don't have their own closing tags,
      // e.g. <div><p></div>.
      while (parent is! RegularElement || parent.name != name) {
        if (loose) {
          // If we previous element did interpret the next opening tag as an
          // attribute, backtrack.
          if (parent is RenderableElement && parent.attributes.isNotEmpty) {
            Attribute last = parent.attributes.last;

            if (last.name == '<$name') {
              index = last.start;
              parent.attributes.removeLast();
              break;
            }
          }
        }

        if (parent is! RegularElement && !loose) {
          if (tag != null && tag.tag == name) {
            elementInvalidClosingTagAutoClosed(start, name, tag.reason);
          } else {
            elementInvalidClosingTag(start, name);
          }
        }

        parent.end = start;
        pop();

        parent = current;
      }

      parent.end = index;
      pop();

      if (tag != null && stack.length < tag.depth) {
        lastAutoClosedTag = null;
      }

      return;
    }

    if (name.startsWith('svelte:') && !_metaTags.contains(name)) {
      svelteMetaInvalidTag(start + 1, start + 1 + name.length, _metaTags);
    }

    if (!_validElementNameRe.hasMatch(name) &&
        !_validComponentNameRe.hasMatch(name)) {
      // <div. -> in the middle of typeing -> allow in loose mode.
      if (!loose || !name.endsWith('.')) {
        tagInvalidName(start + 1, start + 1 + name.length);
      }
    }

    if (_rootOnlyMetaTags.contains(name)) {
      if (metaTags.contains(name)) {
        svelteMetaDuplicate(start, name);
      }

      if (parent is! Root) {
        svelteMetaInvalidPlacement(start, name);
      }

      metaTags.add(name);
    }

    ElementNode element;

    if (name == 'svelte:head') {
      element = SvelteHead(
        start: start,
        fragment: Fragment(children: <Node>[]),
      );
    } else if (name == 'svelte:options') {
      element = SvelteOptions(start: start, attributes: <Attribute>[]);
    } else if (name == 'svelte:window') {
      element = SvelteWindow(start: start, attributes: <Attribute>[]);
    } else if (name == 'svelte:document') {
      element = SvelteDocument(start: start, attributes: <Attribute>[]);
    } else if (name == 'svelte:body') {
      element = SvelteBody(start: start, attributes: <Attribute>[]);
    } else if (name == 'svelte:element') {
      element = SvelteElement(
        start: start,
        tag: null,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    } else if (name == 'svelte:component') {
      element = SvelteComponent(
        start: start,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    } else if (name == 'svelte:self') {
      element = SvelteSelf(
        start: start,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    } else if (name == 'svelte:fragment') {
      element = SvelteFragment(
        start: start,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    } else if (name == 'svelte:boundary') {
      element = SvelteBoundary(
        start: start,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    } else if (_validComponentNameRe.hasMatch(name) ||
        loose && name.endsWith('.')) {
      element = Component(
        start: start,
        name: name,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    } else if (name == 'title' && _parentIsHead(stack)) {
      element = TitleElement(start: start);
    } else if (name == 'slot' && !_parentIsShadowRootTemplate(stack)) {
      element = SlotElement(
        start: start,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    } else {
      element = RegularElement(
        start: start,
        name: name,
        attributes: <Attribute>[],
        fragment: Fragment(children: <Node>[]),
      );
    }

    allowSpace();

    if (parent is RegularElement && closingTagOmitted(parent.name, name)) {
      parent.end = start;
      pop();
      lastAutoClosedTag = (tag: parent.name, reason: name, depth: stack.length);
    }

    // attributes

    if (element is SvelteComponent) {
      throw UnimplementedError('<svelte:component>');
    }

    if (element is SvelteElement) {
      throw UnimplementedError('<svelte:element>');
    }

    // script or style

    add(element);

    bool selfClosing = scan('/') || isVoid(name);
    bool closed = expect('>', false);

    // Loose parsing mode.
    if (!closed) {
      throw UnimplementedError('loose parsing mode');
    }

    if (selfClosing || !closed) {
      // Don't push self-closing elements onto the stack.
      element.end = index;
    } else if (name == 'textarea') {
      throw UnimplementedError('<textarea>');
    } else if (name == 'script' || name == 'style') {
      throw UnimplementedError('<script> or <style>');
    } else {
      stack.add(element);
      fragments.add(element.fragment);
    }
  }
}
