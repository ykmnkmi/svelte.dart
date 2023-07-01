import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_compiler/src/component.dart';
import 'package:svelte_compiler/src/css_mode.dart';
import 'package:svelte_compiler/src/get_name_from_file_name.dart';
import 'package:svelte_compiler/src/interface.dart';

export 'package:svelte_compiler/src/errors.dart' show CompileError;
export 'package:svelte_compiler/src/interface.dart';

void compile(
  String source, {
  CompileOptions options = CompileOptions.defaultOptions,
}) {
  SvelteAst ast = parse(
    source,
    fileName: options.fileName,
    uri: options.uri,
    skipStyle: options.cssMode == CssMode.none,
  );

  List<String> warnings = <String>[];

  Component component = Component(
    ast: ast,
    source: source,
    name: options.name ?? getNameFromFileName(options.fileName) ?? 'Component',
    compileOptions: options,
    warnings: warnings,
  );

  throw UnimplementedError(component.name);
}
