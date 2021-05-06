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

bool closingTagOmitted(String current, String? next) {
  if (disallowedContents.containsKey(current)) {
    if (next == null || disallowedContents[current]!.contains(next)) {
      return true;
    }
  }

  return false;
}

bool isVoid(String tag) {
  tag = tag.toLowerCase();
  return RegExp('^(?:area|base|br|col|command|embed|hr|img|input|keygen|link|meta|param|source|track|wbr)\$').hasMatch(tag) || tag == '!doctype';
}
