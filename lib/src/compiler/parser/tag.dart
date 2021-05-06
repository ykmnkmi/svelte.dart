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

  Attribute? readAttribute(Set<String> uniqueNames) {
    final name = readUntil(RegExp(r'[\s=\/>"' "']"));

    if (name.isEmpty) {
      return null;
    }

    if (uniqueNames.contains(name)) {
      error(code: 'duplicate-attribute', message: 'attributes need to be unique');
    }

    final attribute = Attribute(name);
    uniqueNames.add(name);
    whitespace();

    if (eat('=')) {
      whitespace();
      attribute.value = readAttributeValue();
    } else if (match('["' "']")) {
      error(code: 'unexpected-token', message: 'expected =');
    }

    return attribute;
  }

  Node? readAttributeValue() {
    final mark = read('"') ?? read("'");
    final pattern = RegExp(mark ?? '(\/>|[\s"' "'=<>`])");
    final nodes = <Node>[];
    readSequence((Parser parser) => parser.match(pattern));
    skip(mark);
    return Interpolation.orNode(nodes);
  }

  void readSequence(bool Function(Parser parser) done) {
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        add(Text('$buffer'));
        buffer.clear();
      }
    }

    while (!isDone) {
      if (done(this)) {
        flush();
      } else if (eat('{')) {
        flush();
        whitespace();
        expression();
        whitespace();
        eat('}', required: true);
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

    whitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        error(code: 'invalid-void-content', message: '<$name> is a void element and cannot have children, or a closing tag');
      }

      eat('>', required: true);

      while (parent is! Element || parent.tag != name) {
        if (parent is! Element) {
          invalidClosingTag(name);
        }

        pop();
        parent = current;
      }

      pop();
      forgetLastAutoClosedTag();
      return;
    } else if (parent is Element && closingTagOmitted(parent.tag, name)) {
      pop();
      lastAutoClosedTag = LastAutoClosedTag(parent.tag, name, length);
    }

    final uniqueNames = <String>{};
    var attribute = readAttribute(uniqueNames);

    while (attribute != null) {
      whitespace();
      attribute = readAttribute(uniqueNames);
    }

    add(element);

    final selfClosing = eat('/') || isVoid(name);

    eat('>', required: true);

    if (selfClosing) {
      // don't push self-closing elements onto the stack
    } else if (name == 'textarea') {
      push(element);
      readSequence((Parser parser) => parser.match('</textarea>'));
      skip('</textarea>');
      pop();
    } else if (name == 'script' || name == 'style') {
      push(element);
      add(Text(readUntil(RegExp('</$name>'))));
      eat('</$name>', required: true);
      pop();
    } else {
      push(element);
    }
  }
}
