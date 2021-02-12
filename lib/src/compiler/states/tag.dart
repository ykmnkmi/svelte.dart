import '../nodes.dart';
import '../parser.dart';
import '../utils.dart';
import 'expression.dart';

const String validTagName = r'^\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\-]*';

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
];

const String self = r'^svelte:self(?=[\s/>])';
const String component = r'^svelte:component(?=[\s/>])';

void tag(Parser parser) {
  parser.eat('<', required: true);
  var parent = parser.current;

  if (parser.eat('!--')) {
    final data = parser.readUntil('-->');
    parser.eat('-->', required: true, message: 'comment was left open, expected -->');
    parser.add(Comment(data.trim()));
    return;
  }

  final isClosingTag = parser.eat('/');
  final tag = parser.readTagName();

  if (metaTags.containsKey(tag)) {
    final slug = metaTags[tag]!.toLowerCase();

    if (isClosingTag) {
      if ((tag == '' || tag == '') && parser.current.isNotLeaf) {
        parser.error(code: 'invalid-$slug-content', message: '<$tag> cannot have children');
      } else {
        if (parser.hasMetaTag(tag)) {
          parser.error(code: 'duplicate-$slug', message: 'a component can only have one <$tag> tag');
        }

        if (parser.isNotEmpty) {
          parser.error(code: 'invalid-$slug-placement', message: '<$tag> tags cannot be inside elements or blocks');
        }

        parser.addMetaTag(tag);
      }
    }
  }

  Node element;

  if (metaTags.containsKey(tag)) {
    element = Meta(tag: tag);
  } else if (RegExp('[A-Z]').hasMatch(tag[0]) || tag == 'svelte:self' || tag == 'svelte:component') {
    element = InlineComponent(tag: tag);
  } else if (tag == 'title' && parser.parentIsHead()) {
    element = Title();
  } else if (tag == 'slot') {
    element = Slot();
  } else {
    element = Element(tag);
  }

  parser.whitespace();

  if (isClosingTag) {
    if (isVoid(tag)) {
      parser.error(message: '<$tag> is a void element and cannot have children, or a closing tag');
    }

    parser.eat('>', required: true);

    while (parent is! Element || parent.tag != tag) {
      if (parent is! Element) {
        parser.invalidClosingTag(tag);
      }

      parser.pop();
      parent = parser.current;
    }

    parser.pop();
    parser.forgetLastAutoClosedTag();
    return;
  } else if (parent is Element && closingTagOmitted(parent.tag, tag)) {
    parser.pop();
    parser.lastAutoClosedTag = LastAutoClosedTag(parent.tag, tag, parser.length);
  }

  if (element is InlineComponent) {
    parser.error(code: 'missing-component-definition', message: "<svelte:component> must have a 'this' attribute");
    // parser.error(code: 'invalid-component-definition', message: 'invalid component definition');
  }

  if (tag == 'script' || tag == 'style') {
    parser.eat('>', required: true);

    switch (tag) {
      case 'script':
        script(parser);
        break;
      case 'style':
        style(parser);
        break;
    }

    return;
  }

  parser.add(element);
  parser.eat('/');
  parser.eat('>', required: true);

  if (tag == 'textarea') {
    element.children = parser.readSequenceTo((parser) => parser.match('</textarea>'));
    parser.read('</textarea>');
  } else if (tag == 'script' || tag == 'style') {
    element.children.add(Text(parser.readUntil(RegExp('</$tag>'))));
    parser.eat(RegExp('</$tag>'), required: true);
  } else {
    parser.push(element);
  }
}

extension on Parser {
  void addMetaTag(String metaTag) {
    this.metaTags.add(metaTag);
  }

  void forgetLastAutoClosedTag() {
    if (lastAutoClosedTag != null && stack.length < lastAutoClosedTag!.depth) {
      lastAutoClosedTag = null;
    }
  }

  bool hasMetaTag(String tag) {
    return this.metaTags.contains(tag);
  }

  Never invalidClosingTag(String tag) {
    final message = isLastAutoClosedTag(tag)
        ? '</$tag> attempted to close <$tag> that was already automatically closed by <${lastAutoClosedTag!.reason}>'
        : '</$tag> attempted to close an element that was not open';
    error(code: 'invalid-closing-tag', message: message);
  }

  bool isLastAutoClosedTag(String tag) {
    if (lastAutoClosedTag != null && tag == lastAutoClosedTag!.tag) {
      return true;
    }

    return false;
  }

  bool parentIsHead() {
    for (final node in stack.reversed) {
      if (node is Meta && node.tag == 'Head') {
        return true;
      }

      if (node is Element || node is InlineComponent) {
        break;
      }
    }

    return false;
  }

  List<Node> readSequenceTo(bool Function(Parser parser) done) {
    final chunks = <Node>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        chunks.add(Text(buffer.toString()));
        buffer.clear();
      }
    }

    while (!isDone) {
      if (done(this)) {
        flush();
        return chunks;
      } else if (eat('{')) {
        flush();
        whitespace();
        chunks.add(expression(this));
        whitespace();
        eat('}', required: true);
      } else {
        buffer.write(readChar());
      }
    }

    error(code: 'unexpected-eof', message: 'unexpected end of input');
  }

  String readTagName() {
    if (read(RegExp(self))) {
      var legal = false;

      for (final fragment in stack.reversed) {
        if (legal = fragment is IfBlock || fragment is EachBlock || fragment is InlineComponent) {
          break;
        }
      }

      if (!legal) {
        error(
          code: 'invalid-self-placement',
          message: '<svelte:self> components can only exist inside {#if} blocks, {#each} blocks, or slots passed to components',
        );
      }

      return 'svelte:self';
    }

    if (read(RegExp(component))) {
      return 'svelte:component';
    }

    final name = readUntil(RegExp('(\\s|\\/|>)'));

    if (metaTags.containsKey(name)) {
      return name;
    }

    if (name.startsWith('svelte:')) {
      error(code: 'invalid-tag-name', message: 'valid <svelte:...> tag names are $validMetaTags');
    }

    if (!RegExp(validTagName).hasMatch(name)) {
      error(code: 'invalid-tag-name', message: 'expected valid tag name');
    }

    return name;
  }
}
