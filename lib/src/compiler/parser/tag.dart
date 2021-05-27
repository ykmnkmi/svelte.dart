part of '../parser.dart';

const Map<String, Set<String>> disallowedContents = <String, Set<String>>{
  'li': {'li'},
  'dt': {'dt', 'dd'},
  'dd': {'dt', 'dd'},
  'p': {
    'address',
    'article',
    'aside',
    'blockquote',
    'div',
    'dl',
    'fieldset',
    'footer',
    'form',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'header',
    'hgroup',
    'hr',
    'main',
    'menu',
    'nav',
    'ol',
    'p',
    'pre',
    'section',
    'table',
    'ul'
  },
  'rt': {'rt', 'rp'},
  'rp': {'rt', 'rp'},
  'optgroup': {'optgroup'},
  'option': {'option', 'optgroup'},
  'thead': {'tbody', 'tfoot'},
  'tbody': {'tbody', 'tfoot'},
  'tfoot': {'tbody'},
  'tr': {'tr', 'tbody'},
  'td': {'td', 'th', 'tr'},
  'th': {'td', 'th', 'tr'},
};

bool closingTagOmitted(String current, String next) {
  if (disallowedContents.containsKey(current)) {
    if (disallowedContents[current]!.contains(next)) {
      return true;
    }
  }

  return false;
}

bool isVoid(String tag) {
  tag = tag.toLowerCase();
  return RegExp('^(?:area|base|br|col|command|embed|hr|img|input|keygen|link|meta|param|source|track|wbr)\$').hasMatch(tag) || tag == '!doctype';
}

extension TagParser on Parser {
  static LastAutoClosedTag? lastAutoClosedTag;

  void forgetLastAutoClosedTag() {
    if (lastAutoClosedTag != null && stack.length < lastAutoClosedTag!.depth) {
      lastAutoClosedTag = null;
    }
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

  bool readAttribute(Element element, Set<String> uniqueNames) {
    final name = readUntil(RegExp(r'[\s=\/>"' "']"));

    if (name.isEmpty) {
      return false;
    }

    if (uniqueNames.contains(name)) {
      error(code: 'duplicate-attribute', message: 'attributes need to be unique');
    }

    uniqueNames.add(name);

    if (name.startsWith('on:')) {
      eat('={', required: true);
      whitespace();

      if (!expression()) {
        error(message: 'expected an identifier');
      }

      push(EventListener(name.substring(3), pop()!));
      whitespace();
      eat('}', required: true);
    } else {
      if (eat('=')) {
        throw UnimplementedError();
      } else {
        push(Attribute(name));
      }
    }

    return true;
  }

  void readAttributeValue() {
    eat('"', required: true);
    readSequence((Parser parser) => parser.match('"'));
    eat('"', required: true);
  }

  Iterable<Node> readSequence(bool Function(Parser parser) done) sync* {
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        push(Text('$buffer'));
        buffer.clear();
      }
    }

    while (!isDone) {
      if (done(this)) {
        flush();
        return;
      } else if (match('{')) {
        flush();
        mustache();
        yield pop()!;
      } else {
        buffer.write(template[index++]);
      }
    }

    error(code: 'unexpected-eof', message: 'unexpected end of input');
  }

  String readTagName() {
    final name = readUntil(RegExp('(\\s|\\/|>)'));

    if (name.isEmpty) {
      return 'fragment';
    }

    if (!RegExp(r'\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\-]*').hasMatch(name)) {
      error(code: 'invalid-tag-name', message: 'expected valid tag name, got $name');
    }

    return name;
  }

  void tag() {
    eat('<', required: true);

    var parent = current;

    if (eat('!--')) {
      skipUntil('-->');
      eat('-->', required: true, message: 'comment was left open, expected -->');
      return;
    }

    final isClosingTag = eat('/');
    final name = readTagName();
    final element = Element(name);

    if (isClosingTag) {
      if (isVoid(name)) {
        error(code: 'invalid-void-content', message: '<$name> is a void element and cannot have children, or a closing tag');
      }

      eat('>', required: true);

      while (parent is! Element || parent.tag != name) {
        if (parent is! Element) {
          invalidClosingTag(name);
        }

        stack.removeLast();
        parent = current;
      }

      stack.removeLast();
      forgetLastAutoClosedTag();
      return;
    } else if (parent is Element && closingTagOmitted(parent.tag, name)) {
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(parent.tag, name, length);
    }

    final uniqueNames = <String>{};
    whitespace();

    while (readAttribute(element, uniqueNames)) {
      element.attributes.add(pop() as Attribute);
      whitespace();
    }

    push(element);

    final selfClosing = eat('/') || isVoid(name);

    eat('>', required: true);

    if (selfClosing) {
      // don't push self-closing elements onto the stack
    } else {
      stack.add(element);
    }
  }
}
