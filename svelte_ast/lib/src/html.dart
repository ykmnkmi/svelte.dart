import 'package:svelte_ast/src/entities.dart';

const List<int> windows1252 = <int>[
  0x20AC, 0x0081, 0x201A, 0x0192, //
  0x201E, 0x2026, 0x2020, 0x2021, //
  0x02C6, 0x2030, 0x0160, 0x2039, //
  0x0152, 0x008D, 0x017D, 0x008F, //
  0x0090, 0x2018, 0x2019, 0x201C, //
  0x201D, 0x2022, 0x2013, 0x2014, //
  0x02DC, 0x2122, 0x0161, 0x203A, //
  0x0153, 0x009D, 0x017E, 0x0178
];

String _regExpEntity(String entityName, bool isAttributeValue) {
  // https://html.spec.whatwg.org/multipage/parsing.html#named-character-reference-state
  // doesn't decode the html entity which not ends with ; and next character is =, number or alphabet in attribute value.
  if (isAttributeValue && !entityName.endsWith(';')) {
    return '$entityName\\b(?!=)';
  }

  return entityName;
}

RegExp _getEntityPattern(bool isAttributeValue) {
  Iterable<String> regExpEntities = entities.keys
      .map<String>((entityName) => _regExpEntity(entityName, isAttributeValue));
  return RegExp('&(#(?:x[a-fA-F\\d]+|\\d+)(?:;)?|${regExpEntities.join('|')})');
}

final RegExp _attributeValue = _getEntityPattern(true);

final RegExp _content = _getEntityPattern(false);

int validateCode(int code) {
  return switch (code) {
    // line feed becomes generic whitespace
    10 => 32,
    // ASCII range. (Why someone would use HTML entities for ASCII characters I don't know, but...)
    < 128 => code,
    // code points 128-159 are dealt with leniently by browsers, but they're incorrect. We need
    // to correct the mistake or we'll end up with missing € signs and so on
    <= 159 => windows1252[code - 128],
    // basic multilingual plane
    < 55296 => code,
    // UTF-16 surrogate halves
    <= 57343 => 0,
    // rest of the basic multilingual plane
    <= 65535 => code,
    // supplementary multilingual plane 0x10000 - 0x1ffff
    >= 65536 && <= 131071 => code,
    // supplementary ideographic plane 0x20000 - 0x2ffff
    >= 131072 && <= 196607 => code,
    _ => 0,
  };
}

String decodeCharacterReferences(String string, bool isAttributeValue) {
  RegExp entityPattern = isAttributeValue ? _attributeValue : _content;
  return string.replaceAllMapped(entityPattern, (match) {
    String entity = match[1]!;
    int? code;

    // Handle named entities
    if (entity[0] != '#') {
      code = entities[entity];
    } else if (entity[1] == 'x') {
      code = int.tryParse(entity.substring(2), radix: 16);
    } else {
      code = int.tryParse(entity.substring(1), radix: 10);
    }

    if (code == null) {
      return match.input;
    }

    return String.fromCharCode(validateCode(code));
  });
}

const Map<String, Set<String>> _disallowedContents = <String, Set<String>>{
  'li': <String>{'li'},
  'dt': <String>{'dt', 'dd'},
  'dd': <String>{'dt', 'dd'},
  'p': <String>{
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
    'ul',
  },
  'rt': <String>{'rt', 'rp'},
  'rp': <String>{'rt', 'rp'},
  'optgroup': <String>{'optgroup'},
  'option': <String>{'option', 'optgroup'},
  'thead': <String>{'tbody', 'tfoot'},
  'tbody': <String>{'tbody', 'tfoot'},
  'tfoot': <String>{'tbody'},
  'tr': <String>{'tr', 'tbody'},
  'td': <String>{'td', 'th', 'tr'},
  'th': <String>{'td', 'th', 'tr'},
};

bool closingTagOmitted(String current, [String? next]) {
  Set<String>? disallowed = _disallowedContents[current];

  if (disallowed != null) {
    return next == null || disallowed.contains(next);
  }

  return false;
}
