library;

import 'package:svelte_runtime/src/dom.dart';
import 'package:web/web.dart';

Map<String, Set<Element>> allStyles = <String, Set<Element>>{};

void registerStyle(String hash, Element style) {
  (allStyles[hash] ??= <Element>{}).add(style);
}

void unregisterStyles(String hash) {
  Set<Element>? styles = allStyles.remove(hash);

  if (styles != null) {
    for (Element style in styles) {
      remove(style);
    }
  }
}
