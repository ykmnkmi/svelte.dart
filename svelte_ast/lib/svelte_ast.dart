import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';

export 'package:svelte_ast/src/ast.dart';
export 'package:svelte_ast/src/errors.dart' show ParseError;

final class SvelteAst {
  SvelteAst({required this.html, this.instance, this.module, this.style});

  final Node html;

  final Script? instance;

  final Script? module;

  final Style? style;

  Map<String, Object?> toJson([JsonMapper mapper = toStringMapper]) {
    return <String, Object?>{
      'html': html.toJson(mapper),
      'style': style?.toJson(mapper),
      'instance': instance?.toJson(mapper),
      'module': module?.toJson(mapper),
    };
  }
}

SvelteAst parse(
  String string, {
  String? fileName,
  Uri? uri,
  bool skipStyle = false,
}) {
  Parser parser = Parser(
    string: string.trimRight(),
    fileName: fileName,
    uri: uri,
    skipStyle: skipStyle,
  );

  Script? instance;
  Script? module;

  for (Script script in parser.scripts) {
    if (script.context == 'default') {
      if (instance != null) {
        parser.error(invalidScriptInstance, script.start);
      }

      instance = script;
    } else if (script.context == 'module') {
      if (module != null) {
        parser.error(invalidScriptModule, script.start);
      }

      module = script;
    }
  }

  Style? style;

  if (parser.styles.length == 1) {
    style = parser.styles.first;
  } else if (parser.styles.length > 1) {
    parser.error(duplicateStyle, parser.styles[1].start);
  }

  return SvelteAst(
    html: parser.html,
    instance: instance,
    module: module,
    style: style,
  );
}
