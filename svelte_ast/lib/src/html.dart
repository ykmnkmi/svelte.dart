import 'package:svelte_ast/src/entities.dart';

const List<int> _windows1252 = <int>[
  0x20AC, 0x0081, 0x201A, 0x0192, //
  0x201E, 0x2026, 0x2020, 0x2021, //
  0x02C6, 0x2030, 0x0160, 0x2039, //
  0x0152, 0x008D, 0x017D, 0x008F, //
  0x0090, 0x2018, 0x2019, 0x201C, //
  0x201D, 0x2022, 0x2013, 0x2014, //
  0x02DC, 0x2122, 0x0161, 0x203A, //
  0x0153, 0x009D, 0x017E, 0x0178,
];

String _regExpEntity(String entityName, bool isAttributeValue) {
  // https://html.spec.whatwg.org/multipage/parsing.html#named-character-reference-state
  // doesn't decode the html entity which not ends with ; and next character is
  // =, number or alphabet in attribute value.
  if (isAttributeValue && !entityName.endsWith(';')) {
    return '$entityName\\b(?!=)';
  }

  return entityName;
}

RegExp _getEntityPattern(bool isAttributeValue) {
  Iterable<String> regExpEntities = entities.keys.map<String>((entityName) {
    return _regExpEntity(entityName, isAttributeValue);
  });

  return RegExp('&(#(?:x[a-fA-F\\d]+|\\d+)(?:;)?|${regExpEntities.join('|')})');
}

final RegExp _attributeValue = _getEntityPattern(true);

final RegExp _content = _getEntityPattern(false);

int _validateCode(int code) {
  return switch (code) {
    // Line feed becomes generic whitespace.
    10 => 32,
    // ASCII range.
    < 128 => code,
    // Code points 128-159 are dealt with leniently by browsers, but they're
    // incorrect. We need to correct the mistake or we'll end up with missing €
    // signs and so on.
    <= 159 => _windows1252[code - 128],
    // Basic multilingual plane.
    < 55296 => code,
    // UTF-16 surrogate halves.
    <= 57343 => 0,
    // Rest of the basic multilingual plane.
    <= 65535 => code,
    // Supplementary multilingual plane 0x10000 - 0X1FFFF.
    >= 65536 && <= 131071 => code,
    // Supplementary ideographic plane 0x20000 - 0X2FFFF.
    >= 131072 && <= 196607 => code,
    _ => 0,
  };
}

String decodeCharacterReferences(String string, bool isAttributeValue) {
  RegExp entityPattern = isAttributeValue ? _attributeValue : _content;

  return string.replaceAllMapped(entityPattern, (match) {
    String entity = match[1]!;
    int? code;

    // Handle named entities.
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

    return String.fromCharCode(_validateCode(code));
  });
}

// Map of elements that have certain elements that are not allowed inside them,
// in the sense that they will auto-close the parent/ancestor element.
// Theoretically one could take advantage of it but most of the time it will
// just result in confusing behavior and break when SSR'd.
// There are more elements that are invalid inside other elements, but they're
// not auto-closed and so don't break SSR and are therefore not listed here.
const Map<String, Map<String, List<String>>>
_autoClosingChildren = <String, Map<String, List<String>>>{
  // based on http://developers.whatwg.org/syntax.html#syntax-tag-omission
  'li': <String, List<String>>{
    'direct': ['li'],
  },
  // https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dt#technical_summary
  'dt': <String, List<String>>{
    'descendant': <String>['dt', 'dd'],
    'resetBy': <String>['dl'],
  },
  'dd': <String, List<String>>{
    'descendant': <String>['dt', 'dd'],
    'resetBy': <String>['dl'],
  },
  'p': <String, List<String>>{
    'descendant': <String>[
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
    ],
  },
  'rt': <String, List<String>>{
    'descendant': <String>['rt', 'rp'],
  },
  'rp': <String, List<String>>{
    'descendant': <String>['rt', 'rp'],
  },
  'optgroup': <String, List<String>>{
    'descendant': <String>['optgroup'],
  },
  'option': <String, List<String>>{
    'descendant': <String>['option', 'optgroup'],
  },
  'thead': <String, List<String>>{
    'direct': <String>['tbody', 'tfoot'],
  },
  'tbody': <String, List<String>>{
    'direct': <String>['tbody', 'tfoot'],
  },
  'tfoot': <String, List<String>>{
    'direct': <String>['tbody'],
  },
  'tr': <String, List<String>>{
    'direct': <String>['tr', 'tbody'],
  },
  'td': <String, List<String>>{
    'direct': <String>['td', 'th', 'tr'],
  },
  'th': <String, List<String>>{
    'direct': <String>['td', 'th', 'tr'],
  },
};

/// Returns true if the tag is either the last in the list of siblings and will
/// be autoclosed, or not allowed inside the parent tag such that it will
/// auto-close it. The latter results in the browser repairing the HTML, which
/// will likely result in an error during hydration.
bool closingTagOmitted(String current, [String? next]) {
  var disallowed = _autoClosingChildren[current];

  if (disallowed == null) {
    return false;
  }

  if (next == null) {
    return true;
  }

  return (disallowed['direct'] ?? disallowed['descendant'])!.contains(next);
}
