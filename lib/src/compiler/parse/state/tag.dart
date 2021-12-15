import 'package:piko/src/compiler/parse/errors.dart';
import 'package:piko/src/compiler/parse/read/expression.dart';

import '../../utils/html.dart';
import '../../utils/names.dart';
import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

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

  static late final RegExp validTagNameRe = compile(r'^\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\-]*');

  static late final RegExp selfRe = compile(r'^svelte:self(?=[\s/>])');

  static late final RegExp componentRe = compile(r'^svelte:component(?=[\s/>])');

  static late final RegExp slotRe = compile(r'^svelte:fragment(?=[\s/>])');

  static late final RegExp componentNameRe = compile('^[A-Z].*');

  static late final RegExp tagNameRe = compile(r'(\s|\/|>)');

  bool parentIsHead() {
    for (var node in stack.reversed) {
      var type = node.type;
      if (type == 'Head') return true;
      if (type == 'Element' || type == 'InlineComponent') return false;
    }

    return false;
  }

  void tag() {
    var start = index;

    expect('<');

    var parent = current;

    if (scan('!--')) {
      var data = readUntil('-->');

      if (scan('-->')) {
        current.children.add(Node(type: 'CommentTag', start: start, data: data));
        return;
      }

      error('unclosed-comment', 'comment was left open, expected -->');
    }

    var isClosingTag = scan('/');
    var name = readTagName();
    var slug = metaTags[name];

    if (slug != null) {
      slug = slug.toLowerCase();

      if (isClosingTag) {
        if ((name == 'svelte:window' || name == 'svelte:body') && current.children.isNotEmpty) {
          error('invalid-$slug-content', '<$name> cannot have children', position: current.children.first.start);
        }
      } else {
        if (this.metaTags.contains(name)) {
          error('duplicate-$slug', 'a component can only have one <$name> tag', position: start);
        }

        if (stack.length > 1) {
          error('invalid-$slug-placement', '<$name> cannot be inside elements or blocks', position: start);
        }

        this.metaTags.add(name);
      }
    }

    var type = metaTags[name];

    if (type == null) {
      if (componentNameRe.hasMatch(name) || name == 'svelte:self' || name == 'svelte:component') {
        print('name: ${componentNameRe.hasMatch(name)}');
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

    var element = Node(type: type, name: name, start: start);

    allowWhitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        var message = '<$name> is a void element and cannot have children, or a closing tag';
        error('invalid-void-content', message, position: start);
      }

      expect('>');

      var lastClosedTag = lastAutoClosedTag;

      while (parent.name != name) {
        if (parent.type != 'Element') {
          var code = 'invalid-closing-tag';
          var prefix = '</$name> attempted to close';

          if (lastClosedTag != null && lastClosedTag.tag == name) {
            var message = '$prefix $name that was already automatically closed by ${lastClosedTag.reason}';
            error(code, message, position: start);
          }

          var message = '$prefix an element that was not open';
          error(code, message, position: start);
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
    } else if (closingTagOmitted(parent.name, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(name, name, stack.length);
    }

    // TODO: attribute parsing
    // TODO: svelte:component parsing
    // TODO: top-level script/style parsing

    current.children.add(element);

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
      element.children.add(Node(type: 'Text', data: data, start: start, end: index));
      expect('</$name>');
      element.end = index;
    } else {
      stack.add(element);
    }
  }

  String readTagName() {
    var start = index;

    if (scan(selfRe)) {
      legal:
      {
        for (var fragment in stack.reversed) {
          var type = fragment.type;

          if (type == 'IfBlock' || type == 'EachBlock' || type == 'InlineComponent') {
            break legal;
          }
        }

        invalidSelfPlacement(start);
      }

      return 'svelte:self';
    }

    if (scan(componentRe)) {
      return 'svelte:component';
    }

    if (scan(slotRe)) {
      return 'svelte:fragment';
    }

    var name = readUntil(tagNameRe);
    var meta = metaTags[name];

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

  List<Node> readSequence(Pattern pattern) {
    var buffer = StringBuffer();
    var chunks = <Node>[];

    void flush(int start, int end) {
      if (buffer.isNotEmpty) {
        chunks.add(Node(type: 'Text', data: buffer.toString(), start: start, end: end));
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

        chunks.add(Node(type: 'MustacheTag', data: expression, start: start, end: index));
      } else {
        buffer.writeCharCode(readChar());
      }
    }

    unexpectedEOF();
  }
}
