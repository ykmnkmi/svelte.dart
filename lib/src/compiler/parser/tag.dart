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
    print(current);
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

  Attribute? readAttribute(Element element, Set<String> uniqueNames) {
    void check(String name) {
      if (uniqueNames.contains(name)) {
        error(code: 'duplicate-attribute', message: 'attributes need to be unique');
      }

      uniqueNames.add(name);
    }

    if (eat('{')) {
      whitespace();

      // TODO: spread

      final name = identifier();

      if (name.isEmpty) {
        error(message: 'expect identifier');
      }

      check(name);
      whitespace();
      eat('}', required: true);
      return ValueAttribute(name, Identifier(name));
    }

    final name = readUntil(RegExp(r'[\s=\/>"' "']"));

    if (name.isEmpty) {
      return null;
    }

    if (name.startsWith('on:')) {
      eat('=', required: true);
      mustache();
      whitespace();
      return EventListener(name.substring(3), pop() as Expression);
    }

    return eat('=') ? ValueAttribute(name, Interpolation.orSingle(readAttributeValue())) : Attribute(name);
  }

  Iterable<Expression> readAttributeValue() sync* {
    eat('"', required: true);
    yield* readSequence((Parser parser) => parser.match('"'));
    eat('"', required: true);
  }

  Iterable<Expression> readSequence(bool Function(Parser parser) done) sync* {
    final buffer = StringBuffer();

    Iterable<Text> flush() sync* {
      if (buffer.isNotEmpty) {
        yield Text('$buffer');
        buffer.clear();
      }
    }

    while (!isDone) {
      if (done(this)) {
        yield* flush();
        return;
      } else if (match('{')) {
        yield* flush();
        mustache();
        yield pop() as Expression;
      } else {
        buffer.write(source[index++]);
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
    var parent = current;
    eat('<', required: true);

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
    var attribute = readAttribute(element, uniqueNames);

    while (attribute != null) {
      element.attributes.add(attribute);
      whitespace();
      attribute = readAttribute(element, uniqueNames);
    }

    element.attributes.sort();
    push(element);

    final selfClosing = eat('/') || isVoid(name);
    eat('>', required: true);

    if (selfClosing) {
      // TODO: parse child
    } else {
      stack.add(element);
    }
  }
}
