import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';

export 'package:svelte_ast/src/ast.dart';
export 'package:svelte_ast/src/errors.dart' show ParseError;
export 'package:svelte_ast/src/parser.dart' show CssMode;

final class SvelteAst {
  SvelteAst({
    required this.html,
    this.instance,
    this.module,
    this.style,
  });

  final Node html;

  final Script? instance;

  final Script? module;

  final Style? style;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'html': html.toJson(),
      if (style case Style style?) 'style': style.toJson(),
      if (instance case Script instance?) 'instance': instance.toJson(),
      if (module case Script module?) 'module': module.toJson(),
    };
  }
}

SvelteAst parse(
  String string, {
  String? fileName,
  Uri? uri,
  CssMode? cssMode,
  bool customElement = false,
}) {
  var Parser(
    :Node html,
    :List<Script> scripts,
    :List<Style> styles,
    :Never Function(ErrorCode errorCode, [int? position]) error,
  ) = Parser(
    string: string.trimRight(),
    fileName: fileName,
    uri: uri,
    cssMode: cssMode,
    customElement: customElement,
  );

  Script? instance;
  Script? module;

  for (Script script in scripts) {
    if (script.context == 'default') {
      if (instance != null) {
        error(invalidScriptInstance, script.start);
      }

      instance = script;
      break;
    } else if (script.context == 'module') {
      if (module != null) {
        error(invalidScriptModule, script.start);
      }

      module = script;
      break;
    }
  }

  Style? style;

  if (styles.length == 1) {
    style = styles.first;
  } else if (styles.length > 1) {
    error(duplicateStyle, styles[1].start);
  }

  return SvelteAst(
    html: html,
    instance: instance,
    module: module,
    style: style,
  );
}
