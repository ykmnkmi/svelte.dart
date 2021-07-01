part of '../parser.dart';

extension TagParser on Parser {
  void tag() {
    final parent = current;
    eat('<');

    if (drink('!--')) {
      skipUntil('-->');
      eat('-->', message: 'comment was left open, expected -->');
      return;
    }

    final isClosingTag = drink('/');
    final name = readTagName();

    if (isClosingTag) {
      if (isVoid(name)) {
        error(
            code: 'invalid-void-content',
            message: '<$name> is a void element and cannot have children, or a closing tag');
      }

      eat('>');

      while (parent is! Element || parent.tag != name) {
        if (parent is! Element) {
          invalidClosingTag(name);
        }

        stack.removeLast();
      }

      stack.removeLast();
      forgetLastAutoClosedTag();
      return;
    } else if (parent is Element && closingTagOmitted(parent.tag, name)) {
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(parent.tag, name, length);
    }

    final uniqueNames = <String>{};
    Element element;
    whitespace();

    if (name.startsWith(RegExp('[A-Z]'))) {
      element = Inline(name);
    } else {
      element = Element(name);
    }

    while (readAttribute(uniqueNames)) {
      element.attributes.add(pop() as Attribute);
      whitespace();
    }

    element.attributes.sort();
    push(element);

    if (drink('/') || isVoid(name)) {
      // self-closing tag
    } else if (name == 'textarea') {
      element.children.addAll(readSequence((Parser parser) => parser.match('</textarea>')));
      read('</textarea>');
    } else {
      stack.add(element);
    }

    eat('>');
  }

  bool readAttribute(Set<String> uniqueNames) {
    void check(String name) {
      if (uniqueNames.contains(name)) {
        error(code: 'duplicate-attribute', message: 'attributes need to be unique');
      }

      uniqueNames.add(name);
    }

    if (drink('{')) {
      whitespace();

      // TODO: spread

      if (!identifier()) {
        error(message: 'expect identifier');
      }

      final name = pop() as Identifier;
      check(name.name);
      whitespace();
      eat('}');
      push(name.name == 'style' ? Style(name) : ValueAttribute(name.name, name));
      return true;
    }

    final name = readUntil(RegExp(r'[\s=\/>"' "']"));

    if (name.isEmpty) {
      return false;
    }

    if (name.startsWith('on:')) {
      eat('=');
      mustache();
      push(EventListener(name.substring(3), pop() as Expression));
      return true;
    }

    if (name == 'style') {
      eat('=');
      mustache();
      push(Style(pop() as Expression));
      return true;
    }

    push(drink('=') ? ValueAttribute(name, Interpolation.orSingle(readAttributeValue())) : Attribute(name));
    return true;
  }

  List<Expression> readAttributeValue() {
    eat('"');
    final expressions = readSequence((parser) => parser.match('"'));
    eat('"');
    return expressions;
  }

  List<Expression> readSequence(bool Function(Parser parser) done) {
    final buffer = StringBuffer();
    final start = current.children.length;
    var end = start;

    void flush() {
      if (buffer.isNotEmpty) {
        push(Text('$buffer'));
        buffer.clear();
        end += 1;
      }
    }

    while (!isDone) {
      if (done(this)) {
        flush();
        final range = current.children.getRange(start, end).toList();
        current.children.removeRange(start, end);
        return range.cast<Expression>();
      } else if (match('{')) {
        flush();
        mustache();
        end += 1;
      } else {
        buffer.write(source[index++]);
      }
    }

    error(code: 'unexpected-eof', message: 'unexpected end of input');
  }

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

  String readTagName() {
    final name = readUntil(RegExp('(\\s|\\/|>)'));

    if (name.isEmpty) {
      return 'piko';
    }

    if (!RegExp(r'\!?[a-zA-Z]{1,}:?[a-zA-Z0-9\-]*').hasMatch(name)) {
      error(code: 'invalid-tag-name', message: 'expected valid tag name, got $name');
    }

    return name;
  }
}

bool isVoid(String tag) {
  tag = tag.toLowerCase();
  return RegExp('^(?:area|base|br|col|command|embed|hr|img|input|keygen|link|meta|param|source|track|wbr)\$')
          .hasMatch(tag) ||
      tag == '!doctype';
}

bool closingTagOmitted(String current, String next) {
  if (disallowedContents.containsKey(current)) {
    if (disallowedContents[current]!.contains(next)) {
      return true;
    }
  }

  return false;
}

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
