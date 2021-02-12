import 'typedefs.dart';

const String component = r'^svelte:component(?=[\s/>])';

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

const Map<String, String> metaTags = <String, String>{
  'svelte:head': 'Head',
  'svelte:options': 'Options',
  'svelte:window': 'Window',
  'svelte:body': 'Body',
};

const String self = r'^svelte:self(?=[\s/>])';

const Map<String, Reader> specials = <String, Reader>{
  // // read_script
  // 'script': readScript,
  // // read_style
  // 'style': readStyle,
};

const String voids = 'area|base|br|col|command|embed|hr|img|input|keygen|link|meta|param|source|track|wbr';
