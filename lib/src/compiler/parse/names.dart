final RegExp voidElementNames = RegExp('^(?:'
    'area|base|br|col|command|embed|hr|img|input|'
    'keygen|link|meta|param|source|track|wbr)\$');

bool isVoid(String name) {
  return voidElementNames.hasMatch(name) || '!doctype' == name.toLowerCase();
}
