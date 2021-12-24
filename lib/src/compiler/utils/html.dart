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
  var dissalowed = disallowedContents[current];

  if (dissalowed == null) {
    return false;
  }

  return next == null || dissalowed.contains(next);
}
