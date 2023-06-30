import 'package:svelte_compiler/src/css_mode.dart';
import 'package:svelte_compiler/src/generate_mode.dart';
import 'package:svelte_compiler/src/utils/namespaces.dart';

class CompileOptions {
  static const CompileOptions defaultOptions = CompileOptions();

  const CompileOptions({
    this.name,
    this.fileName,
    this.uri,
    this.generateMode = GenerateMode.dom,
    this.enableSourceMap = true,
    this.debug = false,
    this.accessors = false,
    this.immutable = false,
    this.preserveWhitespace = false,
    this.tag,
    this.namespace,
    this.cssMode = CssMode.injected,
  });

  final String? name;

  final String? fileName;

  final Uri? uri;

  final GenerateMode generateMode;

  final bool enableSourceMap;

  final bool debug;

  final bool accessors;

  final bool immutable;

  final bool preserveWhitespace;

  final String? tag;

  final Namespace? namespace;

  final CssMode cssMode;
}
