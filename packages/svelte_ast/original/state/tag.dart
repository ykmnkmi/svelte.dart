import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/extract_svelte_ignore.dart';

import '../parser.dart';

final RegExp _self = RegExp('^svelte:self(?=[\\s/>])');

final RegExp _component = RegExp('^svelte:component(?=[\\s/>])');

final RegExp _element = RegExp('^svelte:element(?=[\\s/>])');

final RegExp _slot = RegExp('^svelte:fragment(?=[\\s/>])');

final RegExp _validTagNameRe = RegExp('^\\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\\-]*');

final RegExp _tagNameEndRe = RegExp('(\\s|\\/|>)');

final RegExp _capitalLetter = RegExp('[A-Z]');

final RegExp _attributeNameEndRe = RegExp('[\\s=\\/>"\']');

final RegExp _quoteRe = RegExp('["\']');

final RegExp _attributeValueEndRe = RegExp('(\\/>|[\\s"\'=<>`])');

const Map<String, String> _metaTags = <String, String>{
  'svelte:head': 'Head',
  'svelte:options': 'Options',
  'svelte:window': 'Window',
  'svelte:document': 'Document',
  'svelte:body': 'Body',
};

extension TagParser on Parser {
  String readTagName() {
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
    String name = readTagName();

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

    throw UnimplementedError();
  }
}
