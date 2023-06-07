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

int validateCode(int code) {
  return switch (code) {
    10 => 32,
    < 128 => code,
    <= 159 => windows1252[code - 128],
    < 55296 => code,
    <= 57343 => 0,
    <= 65535 => code,
    >= 65536 && <= 131071 => code,
    _ => 0,
  };
}

String decodeCharacterReferences(String string) {
  return string.replaceAllMapped(entityRe, (match) {
    String entity = match[1]!;
    int? code;

    // Handle named entities
    if (entity[0] != '#') {
      code = entities[entity];
    } else if (entity[1] == 'x') {
      code = int.parse(entity.substring(2), radix: 16);
    } else {
      code = int.parse(entity.substring(1), radix: 10);
    }

    if (code == null) {
      return match.input;
    }

    return String.fromCharCode(validateCode(code));
  });
}

const Map<String, Set<String>> disallowedContents = <String, Set<String>>{
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

bool closingTagOmitted(String? current, [String? next]) {
  if (current == null) {
    return false;
  }

  if (disallowedContents[current] case Set<String> disallowed?) {
    return next == null || disallowed.contains(next);
  }

  return false;
}
