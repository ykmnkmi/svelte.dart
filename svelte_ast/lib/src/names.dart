/// Returns `true` if [name] is of a void element.
bool isVoid(String name) {
  return const <String>[
        'area',
        'base',
        'br',
        'col',
        'command',
        'embed',
        'hr',
        'img',
        'input',
        'keygen',
        'link',
        'meta',
        'param',
        'source',
        'track',
        'wbr',
      ].contains(name) ||
      name.toLowerCase() == '!doctype';
}
