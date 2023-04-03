import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

Ast parse(String source, {Object? sourceUrl, CssMode? cssMode}) {
  var parser = Parser(source, sourceUrl: sourceUrl, cssMode: cssMode);

  Script? instance, library;

  for (var node in parser.scripts) {
    if (node.context == 'default') {
      if (instance != null) {
        parser.invalidScriptInstance(node.start);
      }

      instance = node;
    } else if (node.context == 'library') {
      if (library != null) {
        parser.invalidScriptModule(library.start);
      }

      library = node;
    }
  }

  Style? style;

  for (var node in parser.styles) {
    if (style != null) {
      parser.duplicateStyle(node.start);
    }

    style = node;
  }

  return Ast(
    html: parser.html,
    instance: instance,
    library: library,
    style: style,
  );
}
