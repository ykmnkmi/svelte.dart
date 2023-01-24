import 'package:svelte/compiler.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

Ast parse(String source, {Object? sourceUrl, CssMode? cssMode}) {
  var parser = Parser(source, sourceUrl: sourceUrl, cssMode: cssMode);

  Script? instance, module;

  for (var node in parser.scripts) {
    if (node.context == 'default') {
      if (instance != null) {
        parser.invalidScriptInstance(node.start);
      }

      instance = node;
    } else if (node.context == 'module') {
      if (module != null) {
        parser.invalidScriptModule(module.start);
      }

      module = node;
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
    module: module,
    style: style,
  );
}

class Ast {
  Ast({
    required this.html,
    this.instance,
    this.module,
    this.style,
  });

  final Fragment html;

  final Script? instance;

  final Script? module;

  final Style? style;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'html': html.toJson(),
      if (instance != null) 'instance': instance!.toJson(),
      if (module != null) 'module': module!.toJson(),
      if (style != null) 'style': style!.toJson(),
    };
  }
}
